#!/bin/bash
#SBATCH --job-name=longtr_bedfile
#SBATCH --mem=128G
#SBATCH --time=1-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/transform_matrix_%A.out
#SBATCH --error=logs/transform_matrix_%A.err   # Keep error files !

module load miniconda3/20240410
conda activate ds_env

MATRIX_FINAL_DIR="/scratch/rohlfslab/abierly2/LongTR_gf/archaic_matrix"

datamash transpose \
        < "${MATRIX_FINAL_DIR}/all.archaic.txt" \
        > "${MATRIX_FINAL_DIR}/all.archaic.t.txt"

conda deactivate
