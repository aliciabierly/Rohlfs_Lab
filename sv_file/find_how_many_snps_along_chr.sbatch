#!/bin/bash
#SBATCH --job-name=longtr_full_pipeline
#SBATCH --mem=32G
#SBATCH --time=4-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=24
#SBATCH --ntasks=1
#SBATCH --partition=computelong
#SBATCH --account=rohlfslab
#SBATCH --array=1-467%50                # only 35 running at once
#SBATCH --output=logs/longtr_%A_%a.out
#SBATCH --error=logs/longtr_%A_%a.err   # Keep error files !

# this file was created to see how many SNPs and small indels are contained
# within the SV file for the T2T reference that was already created

echo "LongTR full pipeline starting"
date

# MODULES
module load miniconda3/20240410
conda activate longtr_venv
module load samtools
module load parallel/20241222
module load bcftools

### PATHS
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt)
echo "Processing sample: $SAMPLE"

# run in parallel by chromosome
# filters for sv file:
# 1) sample 2) only SNPs 3) only het SNPs
# make into bed format with [start, end) to merge with other file
# VCF file is [start, end]
parallel -j "${SLURM_CPUS_PER_TASK}" \
    SV_FILE="/projects/rohlfslab/abierly2/Rohlfs_Lab/whatshap/filtered_recalibrated.{}.vcf.gz"
    INTERVAL_FILE="chr{}.intervals.bed"
    TEMP_FILE="/projects/rohlfslab/abierly2/Rohlfs_Lab/whatshap/tmp/${SAMPLE}.csv"

    bcftools view -H --samples "$SAMPLE" $SV_FILE | \

    awk -F'\t' 'BEGIN {OFS="\t" {
        n=split($5, alt, ","); gt_n=split($(NF), gt, "|")
        for (i=1; i<=n; i++) {
            valid=1

            if (length($4)!=1 || length(alt[i])!=1 || gt[1]==gt[2]) {
                valid=0
                break
            }
        }

        if (valid) print $1,$2,$2+1

    }' | \

    bedtools intersect -a $INTERVAL_FILE -b - -c | \
    awk '{print $NF}' | \
    paste -s -d "," | \
    sed "s/^/${SAMPLE},/" > "$TEMP_FILE"

:::: {1..22}
