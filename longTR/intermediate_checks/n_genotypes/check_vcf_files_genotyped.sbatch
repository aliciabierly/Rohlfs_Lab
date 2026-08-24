#!/bin/bash
#SBATCH --job-name=longtr_check_vcfs
#SBATCH --mem=32G
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/n_genotype_%A_%a.out
#SBATCH --error=logs/n_genotype_%A_%a.err
#SBATCH --array=1-711%100
#SBATCH --ntasks=1

module load bcftools
SCRATCH="/scratch/rohlfslab/abierly2"
INDIR_MAIN="${SCRATCH}/LongTR" ## CHANGE
IN_DIR="${INDIR_MAIN}/sorted_vcfs"
OUTPUT_DIR="${INDIR_MAIN}/n_genotypes"

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/shared/hannah_alicia_shared_sampleIDs.txt)
SAMPLE_FILE="${IN_DIR}/${SAMPLE}.autosome.no_del.vcf.gz"

OUTPUT_FILE="${OUTPUT_DIR}/${SAMPLE}.n_genotypes_with_del.txt"
mkdir -p "${OUTPUT_DIR}"

N=$(bcftools view -H "$SAMPLE_FILE" | wc -l)
echo -e "${SAMPLE}\t${N}" > "${OUTPUT_FILE}"
