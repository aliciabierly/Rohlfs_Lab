#!/bin/bash
#SBATCH --job-name=longtr_number_of_repeats_check
#SBATCH --mem=48G
#SBATCH --time=3-00:0:00                 # increased time for reliability
#SBATCH --ntasks=1
#SBATCH --partition=computelong
#SBATCH --account=rohlfslab
#SBATCH --array=1-2%2                # only 35 running at once
#SBATCH --output=logs/longtr_repeats_%A_%a.out
#SBATCH --error=logs/longtr_repeats_%A_%a.err   # Keep error files !

echo "LongTR number of repeats check"
date

# MODULES
module load miniconda3/20240410
module load python3

### PATHS
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/shared/hannah_alicia_shared_sampleIDs.txt)
echo "Processing sample: $SAMPLE"

SCRATCH="/scratch/rohlfslab/abierly2"

# Output directories
OUTDIR_MAIN="${SCRATCH}/LongTR"
MERGED_DIR="${OUTDIR_MAIN}/merged_vcfs"
MERGED_VCF="${MERGED_DIR}/${SAMPLE}.merged.vcf.gz"
MERGED_TBI="${MERGED_DIR}/${SAMPLE}.merged.vcf.gz.tbi"

python lontr_number_of_repeats_check.py \
    -i "${MERGED_VCF}" \
    -o "${SAMPLE}.filtered.merged.vcf.gz"
