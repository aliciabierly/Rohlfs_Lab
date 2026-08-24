#!/bin/bash

INPUT_DIR="/scratch/rohlfslab/abierly2/crams/depth"
#INPUT_SAMPLE_FILE="${OUTPUT_DIR}/${SAMPLE}.average_depth_by_chr.txt"
OUTPUT_FILE="/scratch/rohlfslab/abierly2/crams/depth/average_depth_by_sample.txt"

awk '
NR == 1 {
    next
}
FNR == 1 {
    next
}
{
    sum[$1] += $3
    count[$1]++
}
END {
    print "sample\taverage_genome_depth"
    for (sample in sum)
        print sample "\t" sum[sample] / count[sample]
}' "$INPUT_DIR}"/*.average_depth_by_chr.txt | sort -k1,1 > "$OUTPUT_FILE"
