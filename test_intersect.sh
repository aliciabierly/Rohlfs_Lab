### MODULES: import needed module tools
module load bedtools

### TEST: check that intersection tool works correctly
#   should include all rows of a.bed with and without 
#   intersection with b.bed
bedtools intersect -wao -a "a.bed" -b "b.bed"
