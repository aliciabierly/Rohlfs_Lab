#!/bin/bash
#SBATCH --mem=50G
#SBATCH --time=10:00:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=10
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/longtr_%A_%a.out
#SBATCH --error=logs/longtr_%A_%a.err   # Keep error files !

module load miniconda3
conda activate longtr_venv
module load samtools
module load parallel/20241222
module load bcftools

CHR="chr21"
SCRATCH="/scratch/rohlfslab/abierly2"
CATALOG_DIR="${SCRATCH}/LongTR_fgneg1_haplotagged"
CATALOG="${SCRATCH}/LongTR_fgneg1_haplotagged/TR_catalog_normalized_no_monomers_${CHR}.bed"

REF_DIR="/projects/rohlfslab/shared/reference_genomes"
REF="${REF_DIR}/1KG_ONT_VIENNA_t2t_REFERENCE.fa"

# files to make
OUTDIR_MAIN="${SCRATCH}/LongTR_fgneg1_haplotagged_allsamps" ### MUST CHANGE

echo 'make bams list'
BAMSDIR="${OUTDIR_MAIN}/bams"
#BAM_LIST=$(find "$BAMSDIR" -name "*.${CHR}.haplotagged.bam" -type f | paste -sd, -)
BAM_LIST="${OUTDIR}/tmp/bam_list.txt"
find "$BAMSDIR" \
    -name "*.${CHR}.haplotagged.bam" \
    -type f \
    > "$BAM_LIST"

SAMPLE_LIST=$(find "$BAMSDIR" -name "*.${CHR}.haplotagged.bam" -type f \
    | sed 's|.*/||; s|\.chr.*||')
OUTDIR="${OUTDIR_MAIN}/vcf_per_chrom_parallel"
VCF_OUT="${OUTDIR}/${CHR}.vcf.gz"

mkdir -p "${OUTDIR}"
mkdir "${OUTDIR}/tmp"

# split up catalog into smaller files
echo 'split up catalog'
split -l 1000 "${CATALOG}" "${OUTDIR}/tmp/catalog_files"
catalog_files=$(find "${OUTDIR}/tmp" -name 'catalog_*' -type f)

echo 'start longTR process'
export BAM_LIST REF OUTDIR
parallel --jobs 10 '
    catalog={};
    base=$(basename "$catalog");
    echo "Starting {}"
    LongTR \
        --bam-files "$BAM_LIST" \
        --fasta "$REF" \
        --regions "$catalog" \
        --tr-vcf "${OUTDIR}/tmp/${base}.vcf.gz" \
        --min-mean-qual 0 \
        --indel-flank-len 2 \
        --alignment-params -1,-0.458675,-1,-0.458675,-0.00005800168,-1,-1 \
        --log /dev/null  # Discard LongTR verbose logs
   #    --bam-sampls $SAMPLE_LIST \
' ::: $catalog_files

# Index the VCF
tabix -p vcf ${VCF_OUT}

# Clean up intermediate BAM
#rm -f $TEMP_BAM $TEMP_BAM.bai
#rm -r "${OUTDIR}/tmp"
