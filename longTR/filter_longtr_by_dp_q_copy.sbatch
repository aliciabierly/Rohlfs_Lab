#!/bin/bash
#SBATCH --job-name=filter_longtr
#SBATCH --mem=32G
#SBATCH --cpus-per-task=1
#SBATCH --time=6:00:00
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=filter_longtr_%j.out
#SBATCH --error=filter_longtr_%j.err
# File created by Hannah Siegel

module load miniconda3/20240410
# source $(conda info --base)/etc/profile.d/conda.sh
# virtual env I created that has longtr installed on it
# instructions for longTR installation are on longTR github
conda activate longtr_venv
module load samtools
module load parallel/20241222
module load bcftools

SCRATCH="/scratch/rohlfslab/abierly2"
INDIR_MAIN="${SCRATCH}/LongTR"
IN_DIR="${INDIR_MAIN}/merged_vcfs"
FILTERED_DIR="${INDIR_MAIN}/filtered_vcfs"
SORTED_DIR="${INDIR_MAIN}/sorted_vcfs"

mkdir -p "$FILTERED_DIR"
mkdir -p "$SORTED_DIR"

# FILTER SETTINGS
DP_MIN=10
Q_MIN=0.90

for vcf in ${IN_DIR}/*.merged.vcf.gz; do
    base=$(basename "$vcf")
    FILTERED_VCF="${FILTERED_DIR}/${base%.merged.vcf.gz}.filtered.vcf.gz"
    SORTED_VCF="${SORTED_DIR}/${base%.merged.vcf.gz}.sorted.vcf.gz"
    echo "Processing $base ..."
    if [[ -f "$outvcf" && -f "${outvcf}.tbi" ]]; then
        echo "Skipping $base (already processed)"
        continue
    fi

    # Use -Oz to ensure BGZF output
    bcftools view \
        -i "FMT/DP>=${DP_MIN} && FMT/Q>=${Q_MIN}" \
        -Oz \
        -o "$FILTERED_VCF" \
        "$vcf"

    # index the file
    bcftools index -t "$FILTERED_VCF"

    # sort output file, needed for future merge
    bcftools sort "$FILTERED_VCF" -Oz -o "$SORTED_VCF"
    tabix -p vcf "$SORTED_VCF"
done

echo "DONE. Filtered files are complete!"
