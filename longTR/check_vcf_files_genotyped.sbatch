#!/bin/bash
#SBATCH --job-name=longtr_check_vcfs
#SBATCH --mem=32G
#SBATCH --cpus-per-task=2
#SBATCH --time=6:00:00
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=longtr_empty_%j.out
#SBATCH --error=filter_empty_%j.err

SCRATCH="/scratch/rohlfslab/abierly2"
INDIR_MAIN="${SCRATCH}/LongTR"
IN_DIR="${INDIR_MAIN}/merged_vcfs"
#OUT_FILE=""

for f in ${IN_DIR}/*.vcf.gz; do
    n=$(bcftools view -H "$f" | wc -l);
    echo "$n $f";
done
