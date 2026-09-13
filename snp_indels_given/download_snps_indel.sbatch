#!/bin/bash
#SBATCH --job-name=download_snps
#SBATCH --mem=128G
#SBATCH --time=1-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/diwnload_%A.out
#SBATCH --error=logs/download_%A.err   # Keep error files !

module load bcftools
module load miniconda3
conda activate longtr_venv

OUTDIR="/scratch/rohlfslab/abierly2/snps_indels"
SAMPLE_FILE="/projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt"
mkdir -p "${OUTDIR}"

wget -c \
  -O "${OUTDIR}/1KGP.CHM13v2.0.chr1.recalibrated.snp_indel.pass.vcf.gz" \
  "https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/variants/1000_Genomes_Project/chm13v2.0/all_samples_3202/1KGP.CHM13v2.0.chr1.recalibrated.snp_indel.pass.vcf.gz"

bcftools view \
  -S "${SAMPLE_FILE}" \
  "${OUTDIR}/1KGP.CHM13v2.0.chr1.recalibrated.snp_indel.pass.vcf.gz" \
  -Oz \
  -o "${OUTDIR}/selected_samples.chr1.vcf.gz"

tabix -p vcf "${OUTDIR}/selected_samples.chr1.vcf.gz"

#rm "${OUTDIR}/1KGP.CHM13v2.0.chr1.recalibrated.snp_indel.pass.vcf.gz"
