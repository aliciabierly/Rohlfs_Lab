#!/bin/bash

module load bcftools
SPECIFIC_DIR=$1
INPUT_DIR="/scratch/rohlfslab/abierly2/${1}/sorted_vcfs"
OUTPUT_DIR="/scratch/rohlfslab/abierly2/${1}/matrix_final"

for f in "${INPUT_DIR}"/*.autosome.vcf.gz; do
    N_DEL=$(bcftools view -H -i 'ALT="<DEL>"' "$f" | wc -l)
    sample=$(basename "$f" .autosome.vcf.gz)
    printf "%s\t%s\n" "$sample" "$N_DEL"
done > "${OUTPUT_DIR}/deletions.txt"
