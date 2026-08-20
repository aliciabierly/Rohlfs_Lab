#!/bin/bash

# This file will take in a chr, start, end value to pull out TRs from the different runs of LongTR
module load bcftools

CHR=$1
#START=$2
#END=$3
SCRATCH="/scratch/rohlfslab/abierly2"

echo "LongTR:"
bcftools view -H -r "$CHR" "${SCRATCH}/LongTR/sorted_vcfs/HG00096.autosome.vcf.gz"

echo "LongTR_indel2:"
bcftools view -H -r "$CHR" "${SCRATCH}/LongTR_indel2/sorted_vcfs/HG00096.autosome.vcf.gz"

echo "LongTR_gf:"
bcftools view -H -r "$CHR" "${SCRATCH}/LongTR_gf/sorted_vcfs/HG00096.autosome.vcf.gz"

