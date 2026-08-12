#!/bin/bash
#SBATCH --job-name=filter_longtr
#SBATCH --mem=32G
#SBATCH --cpus-per-task=1
#SBATCH --time=6:00:00
#SBATCH --array=1-711%50
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/filter_longtr_%A_%a.out
#SBATCH --error=logs/filter_longtr_%A_%a.err
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
INDIR_MAIN="${SCRATCH}/LongTR_indel2"
IN_DIR="${INDIR_MAIN}/merged_vcfs"
FILTERED_DIR="${INDIR_MAIN}/filtered_vcfs"
SORTED_DIR="${INDIR_MAIN}/sorted_vcfs"

mkdir -p "$FILTERED_DIR"
mkdir -p "$SORTED_DIR"

# FILTER SETTINGS
DP_MIN=10
Q_MIN=0.90

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/shared/hannah_alicia_shared_sampleIDs.txt)
echo "Processing sample: $SAMPLE"


FILTERED_VCF="${FILTERED_DIR}/${SAMPLE}.filtered.vcf.gz"
SORTED_VCF="${SORTED_DIR}/${SAMPLE}.sorted.vcf.gz"

# skip samples that have already been processed
if [[ -f "$SORTED_VCF" && -f "${SORTED_VCF}.tbi" ]]; then
    echo "Skipping $base (already processed)"
    exit 0
fi

# Use -Oz to ensure BGZF output
# filter VCF file
bcftools view \
    -i "FMT/DP>=${DP_MIN} && FMT/Q>=${Q_MIN}" \
    -Oz \
    -o "$FILTERED_VCF" \
    "${IN_DIR}/${SAMPLE}.merged.vcf.gz"

# index the file
bcftools index -t "$FILTERED_VCF"

# sort output file, needed for future merge
bcftools sort "$FILTERED_VCF" -Oz -o "$SORTED_VCF"
tabix -p vcf "$SORTED_VCF"

echo "DONE. Filtered files are complete!"

echo "Remove intermediate files." ### has not been tested
#rm "$FILTERED_VCF" "${IN_DIR}/${SAMPLE}.merged.vcf.gz"
