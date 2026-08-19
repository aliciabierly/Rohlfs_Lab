#!/bin/bash
#SBATCH --job-name=longtr_bedfile
#SBATCH --mem=48G
#SBATCH --time=1-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=rohlfs
#SBATCH --account=rohlfslab
#SBATCH --output=logs/make_matrix_%A.out
#SBATCH --error=logs/make_matrix_%A.err   # Keep error files !
# this file creates a bedfile of the TR length information, converts to lengths to 
# num of repeating motifs, and filters out TRs that are <2.5 repeats long.

module load miniconda3/20240410
# source $(conda info --base)/etc/profile.d/conda.sh
# virtual env I created that has longtr installed on it
# instructions for longTR installation are on longTR github
conda activate longtr_venv
module load samtools
module load parallel/20241222
module load bcftools
module load bedtools

### PATHS
SCRATCH="/scratch/rohlfslab/abierly2"
IN_DIR_MAIN="${SCRATCH}/LongTR_indelneg15"
IN_DIR="${IN_DIR_MAIN}/sorted_vcfs"
BED_DIR="${IN_DIR_MAIN}/bedfiles"
SAMPLE_SORTED_FILE="${IN_DIR}/${SAMPLE}.sorted.vcf.gz"
R_DIR="${IN_DIR_MAIN}/repeats"
SAMPLE_R_FILE="${R_DIR}/${SAMPLE}.r.vcf.gz"
CATALOG="/projects/rohlfslab/shared/TR_catalogs/TR_catalog_normalized.bed"
CATALOG_SORTED="${IN_DIR_MAIN}/TR_catalog_normalized_sorted.bed"
MASTER_TR_DIR="${IN_DIR_MAIN}/master_tr"
MASTER_TR_FILE="${MASTER_TR_DIR}/${SAMPLE}.master_tr.bed"
MATRIX_TEMP_DIR="${IN_DIR_MAIN}/matrix_temp"
MATRIX_FINAL_DIR="${IN_DIR_MAIN}/matrix_final"

# Combine genotype files
for f in "${MATRIX_TEMP_DIR}"/*.gt.txt; do
    printf "%s\t" "$(basename "${f%.gt.txt}")"
    tr -d '\n' < "$f"
    printf "\n"
done > "${MATRIX_FINAL_DIR}/all.gt.txt"

# Combine heterozygosity files
for f in "${MATRIX_TEMP_DIR}"/*.het.txt; do
    printf "%s\t" "$(basename "${f%.het.txt}")"
    tr -d '\n' < "$f"
    printf "\n"
done > "${MATRIX_FINAL_DIR}/all.het.txt"
conda deactivate
