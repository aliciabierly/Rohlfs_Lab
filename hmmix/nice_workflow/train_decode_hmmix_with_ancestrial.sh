#!/bin/bash
#SBATCH --job-name=hmmix
#SBATCH --mem=10G
#SBATCH --time=24:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=3
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --array=1-663%100                # only 35 running at once
#SBATCH --output=logs/hmmix_%A_%a.out
#SBATCH --error=logs/hmmix_%A_%a.err   # Keep error files !

# this file is the same as train_decode_hmmix.sh. BUT it includes 
# ancestrial bcf files to allow us to see if these tracks are associated
# with an ancestrial group we know

echo "hmmix starting: $(date)"

module load samtools
module load bcftools
module load vcftools
module load bedtools
module load parallel
OUTDIR=$1
# OUTDIR="/scratch/rohlfslab/abierly2/hmmix"
GENOME_BED="${OUTDIR}/all_genome.bed"
ADMIX_POP_DIR="/scratch/rohlfslab/abierly2/archaic_vcf"

# make outgroup file!
SAMP_POP_FILE="${OUTDIR}/tmp/population.txt"
OUTGROUP_SAMPLE_IDS="${OUTDIR}/tmp/outgroup_sample_ids.txt"

if [[ ! -f "$OUTGROUP_SAMPLE_IDS" ]]; then
    awk '$2!="AFR" {print $1}' $SAMP_POP_FILE > $OUTGROUP_SAMPLE_IDS
fi

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $OUTGROUP_SAMPLE_IDS)
#wget -P $OUTDIR https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/GCA_009914755.4/chm13v2.0.fa.gz
MODERN_REF="/scratch/rohlfslab/abierly2/hmmix/chm13v2.0.fa.gz"

# can do it in parallel, but might by unneccesary
mkdir -p "${OUTDIR}/archaic_segments"
export OUTDIR SAMPLE GENOME_BED ADMIX_POP_DIR MODERN_REF
parallel -j "${SLURM_CPUS_PER_TASK}" '
    CHR_N1=$(({}*2-1))
    CHR_N2=$(({}*2))

    OBS_FILE="${OUTDIR}/tmp/obs_chr${CHR_N1}_chr${CHR_N2}.${SAMPLE}.txt"
    MUTATIONRATE="${OUTDIR}/tmp/mutationrate_chr${CHR_N1}_chr${CHR_N2}.bed"
    TRAINED="${OUTDIR}/tmp/trained_chr${CHR_N1}_chr${CHR_N2}.${SAMPLE}.json"
    DECODED="${OUTDIR}/tmp/trained_chr${CHR_N1}_chr${CHR_N2}.${SAMPLE}.decoded"

    ADMIX_CHRN1="${ADMIX_POP_DIR}/archaic_merged_chr${CHR_N1}.bcf"
    ADMIX_CHRN2="${ADMIX_POP_DIR}/archaic_merged_chr${CHR_N2}.bcf"
    hmmix train -obs=$OBS_FILE -weights=$GENOME_BED -mutrates=$MUTATIONRATE -out=$TRAINED -haploid
    hmmix decode -extrainfo -obs=$OBS_FILE -weights=$GENOME_BED -mutrates=$MUTATIONRATE -param=$TRAINED -haploid -out=$DECODED -admixpop=$ADMIX_CHRN1,$ADMIX_CHRN2

    HAP1="${OUTDIR}/tmp/trained_chr${CHR_N1}_chr${CHR_N2}.${SAMPLE}.decoded.hap1.txt"
    HAP2="${OUTDIR}/tmp/trained_chr${CHR_N1}_chr${CHR_N2}.${SAMPLE}.decoded.hap2.txt"
    ARCHAIC_SAMPLE_OUT="${OUTDIR}/archaic_segments/chr${CHR_N1}_chr${CHR_N2}.${SAMPLE}.tsv"
    awk -v sample="$SAMPLE" \
        "\$4>=40000 && \$5==\"Archaic\" && \$6>=0.8 && \$7>=10 {print \$0, \"hap1\", sample}" "$HAP1" > "$ARCHAIC_SAMPLE_OUT"
    awk -v sample="$SAMPLE" \
        "\$4>=40000 && \$5==\"Archaic\" && \$6>=0.8 && \$7>=10 {print \$0, \"hap2\", sample}" "$HAP2" >> "$ARCHAIC_SAMPLE_OUT"
    rm $TRAINED $HAP1 $HAP2
' ::: {1..11}

MERGED_SEGMENTS="${OUTDIR}/archaic_segments/${SAMPLE}.txt"
cat "${OUTDIR}/archaic_segments/"*"${SAMPLE}"*.tsv > $MERGED_SEGMENTS
rm "${OUTDIR}/archaic_segments/chr"*"${SAMPLE}"*.tsv
