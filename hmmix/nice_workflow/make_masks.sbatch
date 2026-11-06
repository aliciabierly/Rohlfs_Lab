#!/bin/bash


# some runs use the entire genome, others have accessibility mask

GENOME_DIR="/scratch/rohlfslab/abierly2/hmmix_files/genome_masks"
mkdir -p $GENOME_DIR

# download short reads accessibility mask
wget -P "$GENOME_DIR" \
    "https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/annotation/accessibility/combined_mask.bed"
