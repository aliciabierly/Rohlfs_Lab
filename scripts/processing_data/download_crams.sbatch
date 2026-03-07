#!/bin/bash
#SBATCH --job-name=read_coverge
#SBATCH --partition=compute
#SBATCH --account=rohlfslab

#SBATCH --cpus-per-task=1
#SBATCH --mem=30G
#SBATCH --time=05:00:00
#SBATCH --array=1-711

#SBATCH --output=read_coverge.out
#SBATCH --error=read_coverge.err

### This file downloads all cram and cram.crai files needed for TR genotyping
### VARIABLES
SAMPLES=$HOME/winter/week6/shared_ids.txt
REF=/projects/rohlfslab/shared/reference_genomes/1KG_ONT_VIENNA_t2t_REFERENCE.fa
INDIR=/scratch/rohlfslab/abierly2/crams
CATALOG=/projects/rohlfslab/shared/TR_catalogs/TR_catalog_normalized.bed
OUTTXT=$INDIR/out.txt
sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $SAMPLES)

### MAKE DIRECTORIES
mkdir -p "$INDIR"

### RUN ARRAY OF DOWNLOADS
echo "processing $sample"
wget -P $INDIR https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1KG_ONT_VIENNA/t2t/${sample}.t2t.cram
wget -P $INDIR https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1KG_ONT_VIENNA/t2t/${sample}.t2t.cram.crai
