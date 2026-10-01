#!/bin/bash
#SBATCH --job-name=sv
#SBATCH --mem=100G
#SBATCH --time=20:0:00                 # increased time for reliability
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --array=1-22%5
#SBATCH --output=logs/%A.out
#SBATCH --error=logs/%A.err   # Keep error files !

module load parallel
module load bcftools

CHR="chr${SLURM_ARRAY_TASK_ID}"
SV_FILE="filtered.1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz"
OUT_DIR="/scratch/rohlfslab/abierly2/sv_file"
OUT_FILE="${OUT_DIR}/${CHR}_snp_indel_pass.vcf.gz"

mkdir -p "${OUT_DIR}/tmp"

# gunzip new file
gzip -dc $SV_FILE > "${OUT_DIR}/tmp/${CHR}_tmp.bcf"

# add heterozygousity proportion
bcftools +fill-tags "${OUT_DIR}/tmp/${CHR}_tmp.bcf" -Ob -o "${OUT_DIR}/tmp/${CHR}_tmp_with_het.bcf" -- -t AC_Het

# rezip file
gzip -c "${OUT_DIR}/tmp/${CHR}_tmp_with_het.bcf" > $OUT_FILE

rm -r "${OUT_DIR}/tmp/${CHR}*"
