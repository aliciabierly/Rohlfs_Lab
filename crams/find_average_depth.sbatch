#!/bin/bash
#SBATCH --job-name=cram_depth
#SBATCH --mem=10G
#SBATCH --time=2-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=22
#SBATCH --ntasks=1
#SBATCH --partition=computelong
#SBATCH --account=rohlfslab
#SBATCH --array=1-711%50                # only 35 running at once
#SBATCH --output=logs/cram_depth_%A_%a.out
#SBATCH --error=logs/cram_depth_%A_%a.err   # Keep error files !

module load samtools
module load parallel/20241222

# create file with all chromosomes. Used to calculate the depth average per chr.
for i in {1..22}; do
    echo "chr$i"
done > chromosomes.txt

# pull out sample name
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/shared/hannah_alicia_shared_sampleIDs.txt)
CRAM="/scratch/rohlfslab/abierly2/crams/${SAMPLE}.t2t.cram"
OUTPUT_DIR="/scratch/rohlfslab/abierly2/crams/depth"
OUTPUT_SAMPLE_FILE="${OUTPUT_DIR}/${SAMPLE}.average_depth_by_chr.txt"

mkdir -p "$OUTPUT_DIR"
echo -e "sample\tchromosome\taverage_depth" > "$OUTPUT_SAMPLE_FILE"


echo "Processing sample: $SAMPLE"

### PARALLEL GENOTYPING PER CHROMOSOME
parallel -j "${SLURM_CPUS_PER_TASK}" \
    --colsep '\t' \
    '
    chr={1}
    avg=$(samtools depth -a -r "$chr" "'"${CRAM}"'" | \
        awk "{sum += \$3; n++} END {if (n > 0) print sum/n; else print 0}")
    echo -e "'"$SAMPLE"'\t$chr\t$avg"
    ' :::: chromosomes.txt >> "$OUTPUT_SAMPLE_FILE"
echo "Finished $SAMPLE"
