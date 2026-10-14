#!/bin/bash
#SBATCH --partition=compute              ### Partition (like a queue in PBS)
#SBATCH --account=rohlfslab          ### Account used for job submission
#SBATCH --job-name="liftover_t2t_hg38"          ### Job Name
#SBATCH --time=0-01:00:00                ### Wall clock time limit in Days-HH:MM:SS
#SBATCH --nodes=1                        ### Number of nodes needed for the job
#SBATCH --mem=1G                       ### Total Memory for job in MB -- can do K/M/G/T for KB/MB/GB/TB
#SBATCH --cpus-per-task=1                ### Number of cpus/cores to be launched per Task

LIFTOVER=/gpfs/projects/rohlfslab/software/liftover/liftOver
CATALOG="/projects/rohlfslab/shared/TR_catalogs/TR_catalog_normalized.bed"
OUTPUT_DIR="/scratch/rohlfslab/abierly2/liftover_catalog"
OUTPUT="${OUTPUT_DIR}/hg38_coordinates.bed"
UNMAPPED="${OUTPUT_DIR}/unmapped.bed"
mkdir -p "$OUTPUT_DIR"
#wget https://hgdownload.soe.ucsc.edu/goldenPath/hs1/liftOver/hs1ToHg38.over.chain.gz
#gzip -dc "hs1ToHg38.over.chain.gz" > "hs1ToHg38.over.chain"
$LIFTOVER -bedPlus=3 -tab -minMatch=0.9 "$CATALOG" hs1ToHg38.over.chain "$OUTPUT" "$UNMAPPED"

awk 'NR % 2 != 0' "$UNMAPPED" | sort | uniq -c
