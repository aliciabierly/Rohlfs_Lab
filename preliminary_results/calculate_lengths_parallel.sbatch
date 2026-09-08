#!/bin/bash
#SBATCH --job-name=longtr_bedfile
#SBATCH --mem=20G
#SBATCH --time=1-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=20
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/make_matrix_%A.out
#SBATCH --error=logs/make_matrix_%A.err   # Keep error files !

module load miniconda3
module load parallel
conda activate ds_env

ARCHAIC_MATRIX="/scratch/rohlfslab/abierly2/LongTR_gf/archaic_matrix/all.archaic.t.txt"
TR_MATRIX="/scratch/rohlfslab/abierly2/LongTR_gf/matrix_final/all.gt.t.txt"
TR_CATALOG="/scratch/rohlfslab/abierly2/LongTR_gf/TR_catalog_normalized_sorted.bed"
OUTPUT_DIR="/scratch/rohlfslab/abierly2/merge_calcs"
ROWS_FILE="${OUTPUT_DIR}/temp/rows_with_1.txt"
SAMPLES="/projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt"

mkdir -p "$OUTPUT_DIR"
mkdir -p "${OUTPUT_DIR}/temp"

#parallel -j "$SLURM_CPUS_PER_TASK" 'python3 python_script_one_line.py "{}"' :::: "${OUTPUT_DIR}/temp/combine_input.txt" > "${OUTPUT_DIR}/summary_table.tsv"

parallel -j "$SLURM_CPUS_PER_TASK" --pipepart \
    -a "${OUTPUT_DIR}/temp/combine_input.txt" \
    --block 100M \
    python3 calculate_lengths_python_2.py \
    > "${OUTPUT_DIR}/summary_table.tsv"

conda deactivate ds_env
