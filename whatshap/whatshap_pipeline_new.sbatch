#!/bin/bash

#SBATCH --job-name=filter_longtr
#SBATCH --mem=32G
#SBATCH --cpus-per-task=1
#SBATCH --time=10:00:00
#SBATCH --array=1-5%5
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/filter_longtr_%A_%a.out
#SBATCH --error=logs/filter_longtr_%A_%a.err
#SBATCH --mail-user=abierly2@uoregon.edu

module load miniconda3/20240410
conda activate whatshap_env

module load samtools
module load bcftools

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" \
    /projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt)

echo "Processing sample: $SAMPLE"

VARIANT_FILE="filtered.1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz"

REF_DIR="/projects/rohlfslab/shared/reference_genomes"
SCRATCH="/scratch/rohlfslab/abierly2"
REF="${REF_DIR}/1KG_ONT_VIENNA_t2t_REFERENCE.fa"

OUTDIR="${SCRATCH}/whatshap"
CRAM="${SCRATCH}/crams/${SAMPLE}.t2t.cram"

PHASED_VCF="${OUTDIR}/phased_vcfs/${SAMPLE}.phased.vcf.gz"
QUAL_BAM="${OUTDIR}/${SAMPLE}.with_qual.bam"
HAP_BAM="${OUTDIR}/${SAMPLE}.haplotagged.bam"

mkdir -p "${OUTDIR}/phased_vcfs"


# --------------------------------------------------
# 1. Extract sample from phased VCF
# --------------------------------------------------

bcftools view \
    -r chr1 \
    -s "$SAMPLE" \
    "$VARIANT_FILE" \
    -Oz \
    -o "$PHASED_VCF"
bcftools index "$PHASED_VCF"


# --------------------------------------------------
# 2. Create temporary BAM with QUAL=0
# --------------------------------------------------

samtools view -h --reference "$REF" "$CRAM" chr1 | \
perl -F'\t' -lane '
    if ($F[0] =~ /^@/) {
        print;
        next;
    }

    if ($F[9] ne "*" && $F[10] eq "*") {
        $F[10] = "0" x length($F[9]);
    }

    print join("\t", @F);
' | \
samtools view -b -o "$QUAL_BAM" -

samtools index "$QUAL_BAM"


# --------------------------------------------------
# 3. Haplotag
# --------------------------------------------------

whatshap haplotag \
    --reference "$REF" \
    "$PHASED_VCF" \
    "$QUAL_BAM" \
    -o "$HAP_BAM"


# --------------------------------------------------
# 4. Index final BAM
# --------------------------------------------------

samtools index "$HAP_BAM"


# --------------------------------------------------
# 5. Remove temporary files
# --------------------------------------------------

rm -f \
    "$QUAL_BAM" \
    "${QUAL_BAM}.bai" \
    "$PHASED_VCF" \
    "${PHASED_VCF}.csi"

echo "Finished $SAMPLE"
echo "Final BAM: $HAP_BAM"
