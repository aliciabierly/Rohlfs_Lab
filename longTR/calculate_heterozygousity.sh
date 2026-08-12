#!/bin/bash

INPUT_DIR="/scratch/rohlfslab/abierly2/LongTR_indel2"
INPUT_FILE="${INPUT_DIR}/matrix_final/all.het.t.txt"
CATALOG="${INPUT_DIR}/TR_catalog_normalized_sorted.bed"
INITIAL_OUTPUT="${INPUT_DIR}/matrix_final/initial_het.txt"
OUTPUT_FILE="${INPUT_DIR}/matrix_final/het_indel2.txt"

awk -F'\t' 'BEGIN { OFS="\t" }
NR > 1 {
    het=0
    called=0

    for (i=1; i<=NF; i++) {
        if ($i == "1") {
            het++
            called++
        }
        else if ($i == "0") {
            called++
        }
    }

    if (called > 0)
        print called, het/called
    else
        print 0, "NA"
}' "$INPUT_FILE" > "$INITIAL_OUTPUT"

paste "$CATALOG" "$INITIAL_OUPUT" > "$OUTPUT_FILE"
rm "$INITIAL_OUPUT"
