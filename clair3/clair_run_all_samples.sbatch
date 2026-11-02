#!/bin/bash
#SBATCH --job-name=clair3
#SBATCH --mem=32G
#SBATCH --time=4:00:00                 # increased time for reliability
#SBATCH --cpus-per-task=24
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --array=1-1%1                # only 35 running at once
#SBATCH --output=logs/longtr_%A_%a.out
#SBATCH --error=logs/longtr_%A_%a.err   # Keep error files !

echo "LongTR full pipeline starting"
date

# MODULES
module load miniconda3/20240410
# source $(conda info --base)/etc/profile.d/conda.sh
# virtual env I created that has longtr installed on it
# instructions for longTR installation are on longTR github
conda activate clair3_env
module load samtools
module load parallel/20241222
module load bcftools

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt) 
echo "Processing sample: $SAMPLE"

REF_DIR="/projects/rohlfslab/shared/reference_genomes"
SCRATCH="/scratch/rohlfslab/abierly2"
REF="${REF_DIR}/1KG_ONT_VIENNA_t2t_REFERENCE.fa"
CATALOG_DIR="/projects/rohlfslab/shared/TR_catalogs"
CATALOG="${CATALOG_DIR}/TR_catalog_normalized.bed"
CATALOG_AUTOSOMES="TR_catalog_chr1-22.bed"
CRAM="${SCRATCH}/crams/${SAMPLE}.t2t.cram"
CRAI="${CRAM}.crai"
BAM="${SCRATCH}/bams/${SAMPLE}.t2t.bam"
OUTPUT_DIR="${SCRATCH}/clair3"
# create bam files
mkdir -p "${SCRATCH}/bams"
mkdir -p "${OUTPUT_DIR}"

# create catalog with only chr 1-22
# awk '$1 ~ /^chr([1-9]|1[0-9]|2[0-2])$/' /projects/rohlfslab/shared/TR_catalogs/TR_catalog_normalized.bed | sort -k1,1V -k2,2n > TR_catalog_chr1-22.bed

# check if the bam index exists, if not make the bam file
if [! -f "${BAM}.bai"]; then 

fi

MODEL_NAME="r941_prom_sup_g5014"

run_clair3.sh \
  --bam_fn="${BAM}" \
  --ref_fn="${REF}" \
  --threads=22 \
  --platform=ont \
  --model_path="${OUTPUT_DIR}/r941_prom_sup_g5014" \
  --output="${OUTPUT_DIR}" \
  --bed_fn="${CATALOG}"
