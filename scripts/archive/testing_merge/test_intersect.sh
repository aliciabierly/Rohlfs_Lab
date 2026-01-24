### These codes were created to test bedtools intersect before merging TR and archaic data
### MODULES: import needed module tools
module load bedtools
SAMPLE="HG0009"
OUT_DIR="OUTPUTS"
mkdir -p $OUT_DIR
### TEST: check that intersection tool works correctly
#   should include all rows of ${SAMPLE}.tr.bed with and without 
#   intersection with ${SAMPLE}.archaic.bed

#   create temperary file for a.bed
#   intersect is NOT inclusive of starting value of a.bed,
#   to combat this, subtract 1 from the start unless start=0
temp_tr=$(mktemp)
awk 'BEGIN{OFS="\t"} { if ($2 > 0) $2--; print }' "${SAMPLE}.tr.bed" > "$temp_tr"

### USE LEFT OUTER JOIN TO INCLUDE ALL TRS
#bedtools intersect -wa -wb -filenames -a "$temp_tr" -b "${SAMPLE}.hap1.archaic.bed" > "${OUT_DIR}/${SAMPLE}.hap1.overlap.tsv"
bedtools intersect -loj -a "$temp_tr" -b "${SAMPLE}.hap1.archaic.bed" | awk 'BEGIN{OFS="\t"} { print $1,$2,$3,$4,$5,$6,$7,$8 }' > "${OUT_DIR}/${SAMPLE}.hap1.overlaps.tsv"
bedtools intersect -loj -a "$temp_tr" -b "${SAMPLE}.hap2.archaic.bed" | awk 'BEGIN{OFS="\t"} { print $1,$2,$3,$4,$5,$6,$7,$8 }' > "${OUT_DIR}/${SAMPLE}.hap2.overlaps.tsv"
bedtools intersect -v -a "${SAMPLE}.hap1.archaic.bed" -b "$temp_tr" > "${OUT_DIR}/${SAMPLE}.hap1.no.overlaps.archaic.bed"
bedtools intersect -v -a "${SAMPLE}.hap2.archaic.bed" -b "$temp_tr" >> "${OUT_DIR}/${SAMPLE}.hap2.no.overlaps.archaic.bed"

rm "$temp_tr"
