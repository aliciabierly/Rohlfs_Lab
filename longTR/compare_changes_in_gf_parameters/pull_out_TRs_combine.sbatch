#!/bin/bash
#SBATCH --job-name=longtr_full_pipeline
#SBATCH --mem=10G
#SBATCH --time=6:0:00                 # increased time for reliability
#SBATCH --partition=computelong
#SBATCH --account=rohlfslab
#SBATCH --output=logs/longtr_combine_%A.out
#SBATCH --error=logs/longtr_combine_%A.err   # Keep error files !

SCRATCH="/scratch/rohlfslab/abierly2"
TR_BED="TRs_of_interest_noheader.bed"
OUTDIR_MAIN="${SCRATCH}/compare_changes_gf" ### MUST CHANGE
OUTFILE_NEG1="${OUTDIR_MAIN}/${SAMPLE}_neg1.txt"
OUTFILE_NEG10="${OUTDIR_MAIN}/${SAMPLE}_neg10.txt"
COMBINE_FILE="${OUTDIR_MAIN}/combine_file.txt"

# combine files
for f in "${OUTDIR_MAIN}"/*_neg1.txt; do
    sample=$(basename "$f" _neg1.txt)
    sed "s/^/-1\t${sample}\t/" "$f"
done > "$COMBINE_FILE"

for f in "${OUTDIR_MAIN}"/*_neg10.txt; do
    sample=$(basename "$f" _neg10.txt)
    sed "s/^/-10\t${sample}\t/" "$f"
done >> "$COMBINE_FILE"
