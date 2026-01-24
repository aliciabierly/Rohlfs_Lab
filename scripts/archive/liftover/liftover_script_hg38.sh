#!/bin/bash
touch hg38_1000g_segments.bed
touch hg38_1000g_segments_output.txt
awk 'NR>1 {print $5, $6, $7}' hg38_1000g_segments.txt > hg38_1000g_segments.bed
python3 liftover_script_hg38.py > hg38_1000g_segments_output.txt

#touch temp_file.txt
#cp hg38_1000g_segments_output.txt temp_file.txt
#awk '{gsub(/\[\(|\)\]/,""); print $2, $3, $4, $5, $6, $7, $8, $9}' temp_file.txt > hg38_1000g_segments_output.txt

#rm temp_file.txt
#touch hg38_1000g_segments_2merge.txt
#touch output.txt
#echo "chrom_start, ch13_start, strand_start, ref_start, chrom_end, ch13_end, strand_end, ref_end" > hg38_1000g_segments_2merge.txt
#cat hg38_1000g_segments_output.txt >> hg38_1000g_segments_2merge.txt
#awk '{gsub(/, /,"\t"); print}' hg38_1000g_segments_2merge.txt > output.txt

#touch hg38_t2t_merged.txt
#paste hg38_1000g_segments.txt output.txt > hg38_t2t_merged.txt
#rm output.txt
#rm hg38_1000g_segments.bed
#rm hg38_1000g_segments_output.txt
rm hg38_1000g_segments_2merge.txt
