#!/bin/bash
#SBATCH --job-name=filter_longtr
#SBATCH --mem=32G
#SBATCH --cpus-per-task=2
#SBATCH --time=6:00:00
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=filter_longtr_%j.out
#SBATCH --error=filter_longtr_%j.err
# File created by Hannah Siegel

module load bcftools

#IN_DIR="/scratch/rohlfslab/merged_vcfs"
IN_DIR="/scratch/rohlfslab/abierly2/mucin/merged"
OUT_DIR="/scratch/rohlfslab/abierly2/mucin/merged_vcfs_filtered"

mkdir -p "$OUT_DIR"

# FILTER SETTINGS
DP_MIN=10
Q_MIN=0.90

for vcf in ${IN_DIR}/*.merged.vcf.gz; do
    base=$(basename "$vcf")
    outvcf="${OUT_DIR}/${base%.merged.vcf.gz}.filtered.vcf.gz"

    echo "Processing $base ..."

    # Use -Oz to ensure BGZF output
    bcftools view \
        -i "FMT/DP>=${DP_MIN} && FMT/Q>=${Q_MIN}" \
        -Oz \
        -o "$outvcf" \
        "$vcf"

    # index the file
    bcftools index -t "$outvcf"

done

echo "DONE. Filtered files in $OUT_DIR"
