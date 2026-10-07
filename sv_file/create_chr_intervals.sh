#!/bin/bash
# this file creates .bed files per chromosome to intersect with the het SNPs

# get the length (bp) per chromosome from CRAM file
LENGTHS=$(samtools view -H /scratch/rohlfslab/abierly2/crams/HG00096.t2t.cram | grep @SQ | awk '{split($3, len, ":"); print len[2]}')

# create bedfile of intervals per chromosome to intersect with het SNPs
for chr_n in {1..22}; do
    FILE="chr${chr_n}.intervals.bed"
    length=$(printf '%s\n' "$LENGTHS" | sed -n "${chr_n}p")

    for ((i=1; i<=$length; i+=1000)); do
        printf '%s\t%s\t%s\n' "chr${chr_n}" "$i" "$((i+1000))"
    done > "$FILE"

done
