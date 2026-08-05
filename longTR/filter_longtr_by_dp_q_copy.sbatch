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

SCRATCH="/scratch/rohlfslab/abierly2"
INDIR_MAIN="${SCRATCH}/LongTR"
IN_DIR="${INDIR_MAIN}/merged_vcfs"
OUT_DIR="${INDIR_MAIN}/filtered_vcfs"

mkdir -p "$OUT_DIR"

# FILTER SETTINGS
DP_MIN=10
Q_MIN=0.90

for vcf in ${IN_DIR}/*.merged.vcf.gz; do
    base=$(basename "$vcf")
    outvcf="${OUT_DIR}/${base%.merged.vcf.gz}.filtered.vcf.gz"

    echo "Processing $base ..."
    if [[ -f "$outvcf" && -f "${outvcf}.tbi" ]]; then
        echo "Skipping $base (already processed)"
        continue
    fi

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
