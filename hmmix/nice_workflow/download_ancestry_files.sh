#!/bin/bash
#SBATCH --job-name=download_archaic
#SBATCH --mem=10G
#SBATCH --time=24:00:00                 # increased time for reliability
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=22
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/%x.out
#SBATCH --error=logs/%x.err   # Keep error files !

module load bcftools
module load parallel

OUTDIR="/scratch/rohlfslab/abierly2"

# download archaic files and extract content
#wget -P $OUTDIR "https://zenodo.org/records/14552025/files/archaic_vcf.tar.gz"
tar -xzf "${OUTDIR}/archaic_vcf.tar.gz" -C "$OUTDIR"

parallel -j "${SLURM_CPUS_PER_TASK}" '

    MAIN_DIR="/scratch/rohlfslab/abierly2/archaic_vcf"
    DEN_DIR="${MAIN_DIR}/altai_Denisovan/chm13"
    NEAN_DIR="${MAIN_DIR}/altai_Neanderthal/chm13"

    CHR_N={}
    DENISOVAN="${DEN_DIR}/output_se.chm13.chr${CHR_N}.vcf.gz"
    NEANDERTHAL="${NEAN_DIR}/output_se.chm13.chr${CHR_N}.vcf.gz"
    DEN_SNPS="${DENISOVAN%.vcf.gz}.snps.vcf.gz"
    NEAN_SNPS="${NEANDERTHAL%.vcf.gz}.snps.vcf.gz"
    MERGED="${MAIN_DIR}/archaic_merged_chr${CHR_N}.vcf.gz"

    bcftools view -v snps -Oz -o "$DEN_SNPS" "$DENISOVAN"
    bcftools index -f "$DEN_SNPS"

    bcftools view -v snps -Oz -o "$NEAN_SNPS" "$NEANDERTHAL"
    bcftools index -f "$NEAN_SNPS"

    bcftools merge -Oz -o "$MERGED" \
        "$DEN_SNPS" "$NEAN_SNPS"
    bcftools index -f "$MERGED"
' ::: {1..22}
