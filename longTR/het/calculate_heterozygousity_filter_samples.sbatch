#!/bin/bash
#SBATCH --job-name=calculate_heterozygousity
#SBATCH --mem=48G
#SBATCH --time=1-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/calculate_heterozygousity_%A.out
#SBATCH --error=logs/calculate_heterozygousity_%A.err   # Keep error files !

INPUT_DIR="/scratch/rohlfslab/abierly2/LongTR_gf"
INPUT_FILE="${INPUT_DIR}/matrix_final/all.het.t.txt"
CATALOG="${INPUT_DIR}/TR_catalog_normalized_sorted.bed"
INITIAL_OUTPUT="${INPUT_DIR}/matrix_final/initial_het.txt"
OUTPUT_FILE="${INPUT_DIR}/matrix_final/het_filtered_samples_dp_30.txt"

SAMPLE_FILE="/projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_30.txt"

awk -F'\t' -v sample_file="$SAMPLE_FILE" '
BEGIN {
    OFS="\t"

    while ((getline sample < sample_file) > 0) {
        keep_sample[sample] = 1
    }

    close(sample_file)
}

NR == 1 {
    for (i = 1; i <= NF; i++) {
        if ($i in keep_sample) {
            keep_col[i] = 1
        }
    }
    next
}

{
    het = 0
    called = 0

    for (i = 1; i <= NF; i++) {
        if (i in keep_col) {
            if ($i == "1/2") {
                het++
                called++
            }
            else if ($i == "1/1") {
                called++
            }
        }
    }

    if (called > 0)
        print called, het/called
    else
        print 0, "NA"
}
' "$INPUT_FILE" > "$INITIAL_OUTPUT"

printf "chr\tstart\tend\tmotif\tn\thet\n" > "$OUTPUT_FILE"
paste "$CATALOG" "$INITIAL_OUTPUT" >> "$OUTPUT_FILE"
rm "$INITIAL_OUTPUT"
