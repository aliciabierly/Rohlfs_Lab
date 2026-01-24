#!/bin/bash

#SBATCH --partition=compute              ### Partition (like a queue in PBS)
#SBATCH --account=rohlfslab          ### Account used for job submission

### NOTE: %u=userID, %x=jobName, %N=nodeID, %j=jobID, %A=arrayMain, %a=arraySub
#SBATCH --job-name="clean_archaic_data"          ### Job Name
#SBATCH --output=/gpfs/scratch/rohlfslab/abierly2/%x.log                  ### File in which to store job output

#SBATCH --time=0-01:00:00                ### Wall clock time limit in Days-HH:MM:SS
#SBATCH --nodes=1                        ### Number of nodes needed for the job
#SBATCH --mem=1G                       ### Total Memory for job in MB -- can do K/M/G/T for KB/MB/GB/TB
#SBATCH --cpus-per-task=1                ### Number of cpus/cores to be launched per Task

### DEFINE VARIABLES
LIFTOVER=/gpfs/projects/rohlfslab/software/liftover/liftOver
OUTDIR="/gpfs/scratch/rohlfslab/abierly2"
INPUTDIR="/gpfs/scratch/rohlfslab/abierly2"
REFERENCE="$OUTDIR/data/hg38-chm13v2.over.chain"

SAMPLE_FILE="$OUTDIR/data/hg38_1000g_segments.txt"
SAMPLE_IDS="/gpfs/projects/rohlfslab/shared/hannah_alicia_shared_sampleIDs.txt"
mkdir -p "$OUTDIR"
mkdir -p "$OUTDIR/data"

#FILTER_IDS="$OUTDIR/data/filtered.ids.tsv"
#FILTER_MEAN_PROB="$OUTDIR/data/filtered.ids.mean.prob.tsv"

### CHECK UNFILTERED DATA IS PRESENT
if [ ! -f $SAMPLE_FILE ]; then
   echo "Sample file doesn't exist, fetching data from HMMIX website"
   wget -P "$OUTDIR/data" "https://zenodo.org/records/14136628/files/hg38_1000g_segments.txt"
fi

if [ ! -f $REFERENCE ]; then
   echo "No reference genome file for lift over, fetching data"
   wget -P "$OUTDIR/data" https://hgdownload.soe.ucsc.edu/hubs/GCA/009/914/755/GCA_009914755.4/liftOver/hg38-chm13v2.over.chain.gz
   gzip -d < "$OUTDIR/data/hg38-chm13v2.over.chain.gz" > "$OUTDIR/data/hg38-chm13v2.over.chain"
fi

### CLEAN DATA
#   filter data for only samples present in TR dataset
echo "Begin filtering"
grep -F -f $SAMPLE_IDS $SAMPLE_FILE > "$OUTDIR/data/hg38_1kg_segments_filtered_id.txt"

# filter data for mean_prob >= 0.75; mean_prob=$8
awk '$8 >= 0.75 {print $0}' "$OUTDIR/data/hg38_1kg_segments_filtered_id.txt" > "$OUTDIR/data/hg38_1kg_segments_filtered_id_prob.txt"

# liftover segments from HG38 -> T2T
echo "liftover"
awk '{
  printf "%s\t%s\t%s", $5, $6, $7
  for (i = 1; i <= NF; i++) {
    if (i != 5 && i != 6 && i != 7) {
      printf "\t%s", $i
    }
  }
  printf "\n"
}' "$OUTDIR/data/hg38_1kg_segments_filtered_id_prob.txt" > "$OUTDIR/data/hg38_1kg_segments_filtered.bed"

$LIFTOVER -bedPlus=3 -tab -minMatch=0.9 "$OUTDIR/data/hg38_1kg_segments_filtered.bed" $OUTDIR/data/hg38-chm13v2.over.chain $OUTDIR/t2t_coordinates_mapped.bed $OUTDIR/t2t_coordinates_unmapped.bed
echo "Processing archaic data complete!"

# remove intermediate files as needed
# rm -r "$OUTDIR/data/" 
