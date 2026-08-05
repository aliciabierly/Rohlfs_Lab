#!/bin/bash
#SBATCH --job-name=longtr_bedfile
#SBATCH --mem=48G
#SBATCH --time=3-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=computelong
#SBATCH --account=rohlfslab
#SBATCH --array=1-711%35                # only 35 running at once
#SBATCH --output=logs/longtr_bedfile_%A_%a.out
#SBATCH --error=logs/longtr_bedfile%A_%a.err   # Keep error files !
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

### PATHS
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/shared/hannah_alicia_shared_sampleIDs.txt)
echo "Processing sample: $SAMPLE"

SCRATCH="/scratch/rohlfslab/abierly2"
IN_DIR="${SCRATCH}/sorted_vcfs"
OUT_DIR="${SCRATCH}/bedfiles"
SAMPLE_FILE="${IN_DIR}/${SAMPLE}.sorted.vcf.gz"
mkdir -p ${OUT_DIR}

BED="${OUT_DIR}/${SAMPLE}.bed"

bcftools query -f "%CHROM\t%START\t%END\t%PERIOD\t%REF\t[%GB]" "${SAMPLE_FILE}" > "${BED}"

python3 find_length_of_trs.py "${BED}"

# python file will run on just the ind files, will multiply the period * 2.5. 
# calculate the len(REF)
# seperate the GB values
# add each GB value to the len(REF)
# compare to period * 2.5 threshold and if higher, count if lower put NA.
