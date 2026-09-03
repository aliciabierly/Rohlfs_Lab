#!/bin/bash
#SBATCH --job-name=merge_TR_archaic_array
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --array=1-467%50
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --time=05:00:00
#SBATCH --output=logs/merge_TR_archaic_%A_%a.out
#SBATCH --error=logs/merge_TR_archaic_%A_%a.err

module load bedtools

SAMPLE_LIST="/projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt"
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLE_LIST")

OUTPUT_DIR="/scratch/rohlfslab/abierly2/merge"
INPUT_FILE="${OUTPUT_DIR}/${SAMPLE}.FINAL.tsv"
TR_CATALOG="/scratch/rohlfslab/abierly2/LongTR_gf/TR_catalog_normalized_sorted.bed"

mkdir -p "$OUTPUT_DIR"
mkdir -p "${OUTPUT_DIR}/temp"

# do this on the .FINAL.tsv files
# take the last two columns and make into _|_ and make into one line seperated by \t
# now merge all of those files together
# do .t and compare directly with the TR loci.
# a "." means that the TR was not genotyped so there was also no archaic data

#bedtools intersect \
#        -a "$TR_CATALOG" \
#        -b "$INPUT_FILE" \
#        -loj \
#	> "${OUTPUT_DIR}/temp/${SAMPLE}.intersect.tsv"

# takes last two columns and makes 0|0, 0|1, 1|0, or 1|1
# binary for whether a particular loci is
awk '{printf "%s%s", ($(NF-1) == "." ? "." : ($(NF-1) != 0 ? 1 : 0)) "|" ($NF == "." ? "." : ($NF != 0 ? 1 : 0)), (NR==1 ? "" : "\t")} END{print ""}' "${OUTPUT_DIR}/temp/${SAMPLE}.intersect.tsv" > "${OUTPUT_DIR}/temp/${SAMPLE}.matrix.tsv"
