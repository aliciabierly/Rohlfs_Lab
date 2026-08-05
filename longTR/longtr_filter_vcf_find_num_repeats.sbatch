#!/bin/bash
#SBATCH --job-name=longtr_find_num_repeats
#SBATCH --mem=48G
#SBATCH --time=3-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=computelong
#SBATCH --account=rohlfslab
#SBATCH --array=1-711%35                # only 35 running at once
#SBATCH --output=logs/longtr_num_repeats_%A_%a.out
#SBATCH --error=logs/longtr_num_repeats_%A_%a.err   # Keep error files !

echo "LongTR find the number of repeats of the TRs per sample"
date

# MODULES
module load miniconda3/20240410
# source $(conda info --base)/etc/profile.d/conda.sh
# virtual env I created that has longtr installed on it
# instructions for longTR installation are on longTR github
module load parallel/20241222
module load bcftools

### PATHS
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/shared/hannah_alicia_shared_sampleIDs.txt)
echo "Processing sample: $SAMPLE"

