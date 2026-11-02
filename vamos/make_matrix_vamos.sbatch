#!/bin/bash
#SBATCH --job-name=vamos_matrix
#SBATCH --mem=64G
#SBATCH --time=1-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/vamos_matrix_%A.out
#SBATCH --error=logs/vamos_matrix_%A.err   # Keep error files !


module load miniconda3
conda activate vamos

MAIN_DIR="/scratch/rohlfslab/abierly2/vamos"
INPUT_DIR="${MAIN_DIR}/merged_vcfs"
OUTPUT_FILE="${MAIN_DIR}/matrix.vcf.gz"
TRYVAMOS_DIR="/projects/rohlfslab/abierly2/Rohlfs_Lab/vamos/vamos_repo/tryvamos"

cd "${TRYVAMOS_DIR}"

#mkdir -p "${MAIN_DIR}/uncompressed_vcfs"
#for vcf in "${MAIN_DIR}"/sorted_vcfs/*.vcf.gz; do
#    base=$(basename "$vcf" .gz)
#    gzip -dc "$vcf" > "${MAIN_DIR}/uncompressed_vcfs/${base}"
#done

find "${MAIN_DIR}/merged_vcfs" -name "*.vcf.gz" | sort > "${MAIN_DIR}/vcf_list.txt"
python3 tryvamos.py \
    combineVCF \
    "${MAIN_DIR}/vcf_list.txt" \
    "${MAIN_DIR}/matrix.vcf.gz"

conda deactivate
