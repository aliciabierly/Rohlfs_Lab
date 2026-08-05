#!/bin/bash
#SBATCH --job-name=longtr_delete_intermediate_files
#SBATCH --mem=4G
#SBATCH --time=1-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/longtr_delete_intermediate_files_%A_%a.out
# This file removes intermediate files from longtr process

SCRATCH="/scratch/rohlfslab/abierly2"
OUTDIR_MAIN="${SCRATCH}/LongTR"

rm -r "${OUTDIR_MAIN}"/longTR_pipeline_*
rm -r "${OUTDIR_MAIN}"/merged_vcfs
