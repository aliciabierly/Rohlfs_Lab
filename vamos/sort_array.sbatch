#!/bin/bash
#SBATCH --job-name=filter_longtr
#SBATCH --mem=32G
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --array=1-467%50
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
INDIR_MAIN="${SCRATCH}/vamos"
IN_DIR="${INDIR_MAIN}/merged_vcfs"
MERGED_DIR="${INDIR_MAIN}/merged_vcfs"
SORTED_DIR="${INDIR_MAIN}/sorted_vcfs"

mkdir -p "$SORTED_DIR"

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt)
echo "Processing sample: $SAMPLE"

MERGED_VCF="${MERGED_DIR}/${SAMPLE}.merged.vcf.gz"
SORTED_VCF="${SORTED_DIR}/${SAMPLE}.sorted.vcf.gz"

# skip samples that have already been processed
if [[ -f "$SORTED_VCF" && -f "${SORTED_VCF}.tbi" ]]; then
    echo "Skipping $base (already processed)"
    exit 0
fi

# sort output file, needed for future merge
# need to add the 2>/dev/null because the RS is not defined
# this results in an error!!
bcftools sort "$MERGED_VCF" -Oz -o "$SORTED_VCF"
tabix -p vcf "$SORTED_VCF"

echo "DONE. Filtered files are complete!"

# bcftools view -H HG01121.merged.vcf.gz 2>/dev/null | tail
