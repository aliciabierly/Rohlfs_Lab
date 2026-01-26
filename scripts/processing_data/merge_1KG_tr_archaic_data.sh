#!/bin/bash
### This file was created in collaboration with Hannah Siegel
### MODULES
module load miniconda3
module load bedtools
module load bcftools
SAMPLE=$1

### DIRECTORIES
VCF_DIR="/gpfs/scratch/rohlfslab/abierly2/merged_vcfs_filtered"
TRACTS_DIR="/gpfs/scratch/rohlfslab/abierly2"

# out directory
OUTDIR="/gpfs/scratch/rohlfslab/abierly2/merge"
OUTDIR_TEMP="/gpfs/scratch/rohlfslab/abierly2/merge/temp"
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
  -f '%CHROM\t%START\t%END0\t[ %MOTIF]\t[ %GT]\t[ PERIOD=%PERIOD;NSKIP=%NSKIP;NFILT=%NFILT;INEXACT_ALLELE=%INEXACT_ALLELE;DP=%DP;DSNP=%DSNP;DFLANKINDEL=%DFLANKINDEL;AN=%AN;REFAC=%REFAC]\t%POS\t%ID\t%REF\t%ALT\t%QUAL\t%FILTER\t%FORMAT\n' \
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
    out=$1
    for(i=2;i<=cols_TR;i++){
         out=out"\t"$i
    }
    h1_start=cols_TR+1
    half=NF/2
    h2_start=half + cols_TR+1
    h1=""
    if ($h1_start != "."){
       for (i = h1_start; i <= half; i++){
           h1 = (h1 == "" ? $i : h1 ";" $i)
       }
    }
    else {h1=0}

    h2=""
    if ($h2_start != "."){
       for (i = h2_start; i <= NF; i++){
          h2 = (h2 == "" ? $i : h2 ";" $i)
       }
    }
    else {h2=0}
    print out "\t" h1 "\t" h2
}' > "$FINAL"
else
    echo "Row counts differ: file1=$rows_hap1, file2=$rows_hap2 for $SAMPLE"
fi

echo "Job done: $(date)"

rm $OUTDIR_TEMP/$SAMPLE*
