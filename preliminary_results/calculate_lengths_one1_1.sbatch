#!/bin/bash
#SBATCH --job-name=longtr_bedfile
#SBATCH --mem=20G
#SBATCH --time=1-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/make_matrix_%A.out
#SBATCH --error=logs/make_matrix_%A.err   # Keep error files !

module load miniconda3

ARCHAIC_MATRIX="/scratch/rohlfslab/abierly2/LongTR_gf/archaic_matrix/all.archaic.t.txt"
TR_MATRIX="/scratch/rohlfslab/abierly2/LongTR_gf/matrix_final/all.gt.t.txt"
TR_CATALOG="/scratch/rohlfslab/abierly2/LongTR_gf/TR_catalog_normalized_sorted.bed"
OUTPUT_DIR="/scratch/rohlfslab/abierly2/merge_calcs_1_1"
ROWS_FILE="${OUTPUT_DIR}/temp/rows_with_1.txt"
SAMPLES="/projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt"

mkdir -p "$OUTPUT_DIR"
mkdir -p "${OUTPUT_DIR}/temp"

# find rows with at least one haplotype from a sample intogressed
awk '{for(i=1;i<=NF;i++) if($i == "1|1") {print NR; break}}' $ARCHAIC_MATRIX > $ROWS_FILE


# filter the two matrices for only the particular rows and only the particular samples
awk 'NR==FNR {rows[$1]=1; next} rows[FNR]' $ROWS_FILE $ARCHAIC_MATRIX > "${OUTPUT_DIR}/filtered.archaic.txt"
awk 'NR==FNR {rows[$1]=1; next} rows[FNR]' $ROWS_FILE $TR_MATRIX > "${OUTPUT_DIR}/filtered.gt.txt"
# no header row in this one
awk 'NR==FNR {rows[$1-1]=1; next} rows[FNR]' \
    "$ROWS_FILE" \
    "$TR_CATALOG" \
    > "${OUTPUT_DIR}/filtered.catalog.txt"

# filter samples
awk 'NR==FNR {keep[$1]=1; next} FNR==1 {for(i=1;i<=NF;i++) if(i==1 || keep[$i]) cols[i]=1} {first=1; for(i=1;i<=NF;i++) if(cols[i]) {if(!first) printf "\t"; printf "%s",$i; first=0} printf "\n"}' "$SAMPLES" "${OUTPUT_DIR}/filtered.gt.txt" > "${OUTPUT_DIR}/filtered.ids.gt.txt"
paste -d ',' \
    "${OUTPUT_DIR}/filtered.catalog.txt" \
    <(tail -n +2 "${OUTPUT_DIR}/filtered.ids.gt.txt") \
    <(tail -n +2 "${OUTPUT_DIR}/filtered.archaic.txt") \
    > "${OUTPUT_DIR}/temp/combine_input.txt"

#parallel -j 10 'python3 python_script_one_line.py "{}"' :::: "${OUTPUT_DIR}/temp/combine_input.txt" > "${OUTPUT_DIR}/summary_table.tsv"
