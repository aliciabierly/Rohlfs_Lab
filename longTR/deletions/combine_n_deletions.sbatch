#!/bin/bash
#SBATCH --job-name=combine_deletions
#SBATCH --mem=10G
#SBATCH --time=1:00:00
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/combine_deletions_%j.out
#SBATCH --error=logs/combine_deletions_%j.err

module load miniconda3
SPECIFIC_DIR="LongTR"
INPUT_DIR="/scratch/rohlfslab/abierly2/${SPECIFIC_DIR}/deletions"

# combine individual files into one
cat "${INPUT_DIR}"/*.deletions.txt \
    > "${INPUT_DIR}/all_deletions.txt"

rm "${INPUT_DIR}"/*.deletions.txt # remove intermediate files

# plot histograms
conda activate ds_env
python3 deletion_plots.py "$SPECIFIC_DIR" "${INPUT_DIR}/all_deletions.txt"
conda deactivate
