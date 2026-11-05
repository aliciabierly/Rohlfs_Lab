#!/bin/bash
#SBATCH --job-name=merge_final_table
#SBATCH --mem=1G
#SBATCH --time=10:00                 # increased time for reliability
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/%x.out
#SBATCH --error=logs/%x.err   # Keep error files !

# this file takes in the outdir and will merge all of the sample files
# that were run as an array in the previous script
# deletes intermediate files

OUTDIR=$1
cat "${OUTDIR}/archaic_segments/"*.txt | \
   sort -k 1,1 -k2,2n \
   > "${OUTDIR}/archaic_segments/merged_archaic_segments.tsv"

rm "${OUTDIR}/archaic_segments/"*.txt
