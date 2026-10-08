#!/bin/bash
#SBATCH --job-name=find_how_many_snps_along_chr
#SBATCH --mem=5G
#SBATCH --time=10:00:00                 # increased time for reliability
#SBATCH --cpus-per-task=5
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --array=1-467%100                # only 35 running at once
#SBATCH --output=logs/longtr_%A_%a.out
#SBATCH --error=logs/longtr_%A_%a.err   # Keep error files !

# this file was created to see how many SNPs and small indels are contained
# within the SV file for the T2T reference that was already created

# more efficient way to do this: array: 1-22
# parallelize by samples to run many at once, one this completes, merge 
# chromosome files all together
# I am too lazy to do this right now

echo "LongTR full pipeline starting"
date

# MODULES
module load miniconda3/20240410
module load samtools
module load parallel/20241222
module load bcftools
module load bedtools

### PATHS
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt)
echo "Processing sample: $SAMPLE"

mkdir -p /scratch/rohlfslab/abierly2/whatshap/tmp/

# run in parallel by chromosome
# filters for sv file:
# 1) sample 2) only SNPs 3) only het SNPs
# make into bed format with [start, end) to merge with other file
# VCF file is [start, end]
parallel -j "${SLURM_CPUS_PER_TASK}" '
    SV_FILE="/projects/rohlfslab/abierly2/Rohlfs_Lab/whatshap/filtered_recalibrated.{}.vcf.gz"
    INTERVAL_FILE="chr{}.intervals.bed"
    TEMP_FILE="/scratch/rohlfslab/abierly2/whatshap/tmp/{}.'"$SAMPLE"'.csv" # this was by chr before!!

    bcftools view -H --samples "'"$SAMPLE"'" "$SV_FILE" |
    awk -F"\t" '\''BEGIN {OFS="\t"} {
        n=split($5, alt, ",")
        gt_n=split($(NF), gt, "|")
        valid=1

        for (i=1; i<=n; i++) {
            if (length($4)!=1 || length(alt[i])!=1 || gt[1]==gt[2]) {
                valid=0
                break
            }
        }

        if (valid) print $1,$2,$2+1
    }'\'' |
    bedtools intersect -a "$INTERVAL_FILE" -b - -c |
    awk '\''{print $NF}'\'' |
    paste -s -d "," |
    sed "s/^/chr{},'"$SAMPLE"',/" >> "$TEMP_FILE"
' ::: {1..22}

# need to make tmp files because file are colliding
