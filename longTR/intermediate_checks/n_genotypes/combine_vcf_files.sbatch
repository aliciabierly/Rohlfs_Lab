#!/bin/bash
#SBATCH --job-name=longtr_check_vcfs
#SBATCH --mem=32G
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/n_genotypes_%A.out
#SBATCH --error=logs/n_genotypes_%A.err
#SBATCH --ntasks=1

module load bcftools
SPECIFIC_DIR="LongTR_gf"
INPUT_DIR="/scratch/rohlfslab/abierly2/${SPECIFIC_DIR}/n_genotypes"

# combine individual files into one
cat "${INPUT_DIR}"/*.n_genotypes*.txt \
    > "${INPUT_DIR}/all_genotypes.txt"

rm -r "${INPUT_DIR}"/*.n_genotypes*.txt
