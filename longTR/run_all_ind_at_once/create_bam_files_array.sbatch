#!/bin/bash
#SBATCH --job-name=longtr_full_pipeline
#SBATCH --mem=10G
#SBATCH --time=8:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --array=1-467%400                # only 35 running at once
#SBATCH --output=logs/longtr_%A_%a.out
#SBATCH --error=logs/longtr_%A_%a.err   # Keep error files !

module load miniconda3
conda activate whatshap_env
module load samtools
module load parallel/20241222
module load bcftools


SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt)
echo "Processing sample: $SAMPLE"

./create_bam_files.sh "chr21" "$SAMPLE"

conda deactivate
