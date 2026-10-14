#!/bin/bash
#SBATCH --job-name=archaic_check
#SBATCH --mem=1G
#SBATCH --time=4:0:00                 # increased time for reliability
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --array=1-467%200                # only 35 running at once
#SBATCH --output=logs/archaic_%A_%a.out
#SBATCH --error=logs/archaic_%A_%a.err   # Keep error files !

module load bedtools

ARCHAIC_TRACTS="/scratch/rohlfslab/abierly2/t2t_coordinates_mapped.bed"
OUTPUT_FILE="/scratch/rohlfslab/abierly2/archaic/homo_vs_het.txt"

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt)

TMPDIR="${SLURM_TMPDIR:-/tmp}"
HAP1="${TMPDIR}/${SAMPLE}.hap1.bed"
HAP2="${TMPDIR}/${SAMPLE}.hap2.bed"

# Extract haplotypes
awk -v sample="$SAMPLE" '$4==sample && $5=="hap1" {print}' \
    "$ARCHAIC_TRACTS" > "$HAP1"

awk -v sample="$SAMPLE" '$4==sample && $5=="hap2" {print}' \
    "$ARCHAIC_TRACTS" > "$HAP2"

# Count overlapping hap1/hap2 tracts
INTERSECTED=$(bedtools intersect -a "$HAP1" -b "$HAP2" -u | wc -l)
INTERSECTED_MULTIPLE=$(bedtools intersect -a "$HAP1" -b "$HAP2" | wc -l)

# Count hap1 tracts with no overlap with hap2
NONINTERSECTED_HAP1=$(bedtools intersect -v -a "$HAP1" -b "$HAP2" | wc -l)

# Count hap2 tracts with no overlap with hap1
NONINTERSECTED_HAP2=$(bedtools intersect -v -a "$HAP2" -b "$HAP1" | wc -l)

echo "$SAMPLE,$INTERSECTED,$INTERSECTED_MULTIPLE,$NONINTERSECTED_HAP1,$NONINTERSECTED_HAP2" >> "$OUTPUT_FILE"

# Clean up
rm "$HAP1" "$HAP2"
