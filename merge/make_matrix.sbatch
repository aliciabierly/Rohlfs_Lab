#!/bin/bash
#SBATCH --job-name=longtr_bedfile
#SBATCH --mem=48G
#SBATCH --time=1-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/make_matrix_%A.out
#SBATCH --error=logs/make_matrix_%A.err   # Keep error files !
# this file creates a bedfile of the TR length information, converts to lengths to
# num of repeating motifs, and filters out TRs that are <2.5 repeats long.

### PATHS
INPUT_DIR="/scratch/rohlfslab/abierly2/merge"
TR_CATALOG="/scratch/rohlfslab/abierly2/LongTR_gf/TR_catalog_normalized_sorted.bed"
ARCHAIC_MATRIX="/scratch/rohlfslab/abierly2/LongTR_gf/archaic_matrix"
mkdir -p "${ARCHAIC_MATRIX}"

# Combine genotype files
for f in "${INPUT_DIR}/temp/"*.matrix.tsv; do
    printf "%s\t" "$(basename "${f%.matrix.tsv}")"
    tr -d '\n' < "$f"
    printf "\n"
done > "${ARCHAIC_MATRIX}/all.archaic.txt"
