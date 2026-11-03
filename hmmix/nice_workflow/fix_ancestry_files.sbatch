#!/bin/bash
#SBATCH --job-name=fix_ancestry_files
#SBATCH --mem=5G
#SBATCH --time=5:00:00
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --array=1-22
#SBATCH --output=logs/%x.out
#SBATCH --error=logs/%x.err

module load bcftools

DEN_DIR="/scratch/rohlfslab/abierly2/archaic_vcf/altai_Denisovan/chm13"
NEAN_DIR="/scratch/rohlfslab/abierly2/archaic_vcf/altai_Neanderthal/chm13"

CHR_N=${SLURM_ARRAY_TASK_ID}
DENISOVAN="${DEN_DIR}/output_se.chm13.chr${CHR_N}.vcf.gz"
NEANDERTHAL="${NEAN_DIR}/output_se.chm13.chr${CHR_N}.vcf.gz"

bcftools view -Ob -o "${DENISOVAN%.vcf.gz}.bcf" "$DENISOVAN"
bcftools index -f "${DENISOVAN%.vcf.gz}.bcf"

bcftools view -Ob -o "${NEANDERTHAL%.vcf.gz}.bcf" "$NEANDERTHAL"
bcftools index -f "${NEANDERTHAL%.vcf.gz}.bcf"
