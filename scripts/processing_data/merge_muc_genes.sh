#!/bin/bash

### MODULES
module load miniconda3
module load bedtools
module load bcftools
SAMPLE=$1
#"HG00096" #$1

### DIRECTORIES
VCF_DIR="/gpfs/scratch/rohlfslab/abierly2/merged_vcfs_filtered"
TRACTS_DIR="/gpfs/scratch/rohlfslab/abierly2"

# out directory
OUTDIR="/gpfs/scratch/rohlfslab/abierly2/merge_reg"
OUTDIR_TEMP="/gpfs/scratch/rohlfslab/abierly2/merge_reg/temp"
mkdir -p $OUTDIR
mkdir -p $OUTDIR_TEMP

### FILE PATHS
VCF="${VCF_DIR}/${SAMPLE}.filtered.vcf.gz"
ARCHAIC_TRACTS="${TRACTS_DIR}/t2t_coordinates_mapped.bed"
ARCHAIC_SAMPLE_TRACTS="${OUTDIR_TEMP}/${SAMPLE}.archaic.txt"

TR_BED="${OUTDIR_TEMP}/${SAMPLE}.TRs.bed"

H1_ARCHAIC_SAMPLE_TRACTS="${OUTDIR_TEMP}/${SAMPLE}.hap1.archaic.bed"
H2_ARCHAIC_SAMPLE_TRACTS="${OUTDIR_TEMP}/${SAMPLE}.hap2.archaic.bed"

H1_INT="${OUTDIR_TEMP}/${SAMPLE}.hap1.overlaps.bed"
H2_INT="${OUTDIR_TEMP}/${SAMPLE}.hap2.overlaps.bed"
H2_INT_ARCHAIC="${OUTDIR_TEMP}/${SAMPLE}.hap2.overlaps.archaic.bed"
NONINT_ARCHAIC="${OUTDIR_TEMP}/${SAMPLE}.nonoverlaps.archaic.bed"

# filepath for final tsv table of merged data per sample
FINAL="${OUTDIR}/${SAMPLE}.FINAL.tsv"

# Split by haplotype (col 5)
grep -w $SAMPLE $ARCHAIC_TRACTS > $ARCHAIC_SAMPLE_TRACTS
awk '$5=="hap1"' "$ARCHAIC_SAMPLE_TRACTS" > "$H1_ARCHAIC_SAMPLE_TRACTS"
awk '$5=="hap2"' "$ARCHAIC_SAMPLE_TRACTS" > "$H2_ARCHAIC_SAMPLE_TRACTS"

### 2. Convert TR VCF to BED file
### KEEP ALL INFORMATION
echo "Converting TR VCF → BED with all fields: $(date)"

TEMP_TR="${OUTDIR_TEMP}/${SAMPLE}.TEMP_TR.bed"
FIXED_TR="${OUTDIR_TEMP}/${SAMPLE}.FIXED_TR.bed"
bcftools query \
  -f '%CHROM\t%START\t%END0\t[ %MOTIF]\t[ %GT]\t%REF\t%ALT\n' \
  "$VCF" > "$TEMP_TR"

### 3. add flanking

### 4. find intersections
echo "Running bedtools intersect: $(date)"

bedtools intersect -loj -a "$TEMP_TR" -b "$H1_ARCHAIC_SAMPLE_TRACTS" > "$H1_INT"
bedtools intersect -loj -a "$TEMP_TR" -b "$H2_ARCHAIC_SAMPLE_TRACTS" > "$H2_INT"
bedtools intersect -v -a "$H1_ARCHAIC_SAMPLE_TRACTS" -b "$TEMP_TR" > "$NONINT_ARCHAIC"
bedtools intersect -v -a "$H2_ARCHAIC_SAMPLE_TRACTS" -b "$TEMP_TR" >> "$NONINT_ARCHAIC"

### 5. Combine into final table with all info from both datasets
echo "Combining haplotypes: $(date)"
# we can remove the first 13 rows from hap2 seq. file because TR info is exactly the same
# we have to check to make sure each file has the same number of rows, then we can paste
rows_hap1=$(wc -l < "$H1_INT")
rows_hap2=$(wc -l < "$H2_INT")
cols_TR=$(head -n 1 $TEMP_TR | awk -F'\t' 'NR==1 {print NF}')
cols_archaic=$(head -n 1 $H1_ARCHAIC_SAMPLE_TRACTS | awk -F'\t' 'NR==1 {print NF}')

if [ "$rows_hap1" -eq "$rows_hap2" ]; then
    echo "Row counts match: $rows_hap1 for $SAMPLE"
    paste $H1_INT $H2_INT |
    awk -F'\t' -v cols_TR="$cols_TR" '{

    if ($5==" 0|0") {
        h1_TR=length($6)
        h2_TR=length($6)
    }
    else if ($5==" 1|0" || $5==" 0|1") {
        h1_TR=length($6)
        h2_TR=length($7)
    }
    else if ($5==" 1|2" || $5==" 2|1") {
        split($7, TR_seqs, ",")
        h1_TR=length(TR_seqs[1])
        h2_TR=length(TR_seqs[2])
    }
    else if ($5 == " 1|1") {
        h1_TR=length($7)
        h2_TR=length($7)
    }
    else {
        h1_TR = "."
        h2_TR = "."
    }

    h1_start=cols_TR+1
    half=NF/2
    h2_start=half + cols_TR+1

    h1_archaic=""
    if ($h1_start != "."){
           h1_archaic=1
    }
    else {h1_archaic=0}

    h2_archaic=""
    if ($h2_start != "."){
          h2_archaic = 1
    }
    else {h2_archaic=0}
    print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" h1_TR "\t" h2_TR "\t" h1_archaic "\t" h2_archaic
}' > "$FINAL"
else
    echo "Row counts differ: file1=$rows_hap1, file2=$rows_hap2 for $SAMPLE"
fi
head "$TEMP_TR"
head "$H1_ARCHAIC_SAMPLE_TRACTS"
head "$H2_ARCHAIC_SAMPLE_TRACTS"

echo "Job done: $(date)"

# rm $OUTDIR_TEMP/$SAMPLE*
