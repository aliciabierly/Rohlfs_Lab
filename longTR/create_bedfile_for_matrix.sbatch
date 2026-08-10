#!/bin/bash
#SBATCH --job-name=longtr_bedfile
#SBATCH --mem=10G
#SBATCH --time=1-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --array=1-711%35                # only 35 running at once
#SBATCH --output=logs/longtr_bedfile_%A_%a.out
#SBATCH --error=logs/longtr_bedfile%A_%a.err   # Keep error files !
# this file creates a bedfile of the TR length information, converts to lengths to 
# num of repeating motifs, and filters out TRs that are <2.5 repeats long.

module load miniconda3/20240410
# source $(conda info --base)/etc/profile.d/conda.sh
# virtual env I created that has longtr installed on it
# instructions for longTR installation are on longTR github
conda activate longtr_venv
module load samtools
module load parallel/20241222
module load bcftools
module load bedtools

### PATHS
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/shared/hannah_alicia_shared_sampleIDs.txt)
echo "Processing sample: $SAMPLE"

SCRATCH="/scratch/rohlfslab/abierly2"
IN_DIR_MAIN="${SCRATCH}/LongTR"
IN_DIR="${IN_DIR_MAIN}/sorted_vcfs"
BED_DIR="${IN_DIR_MAIN}/bedfiles"
SAMPLE_SORTED_FILE="${IN_DIR}/${SAMPLE}.sorted.vcf.gz"
R_DIR="${IN_DIR_MAIN}/repeats"
SAMPLE_R_FILE="${R_DIR}/${SAMPLE}.r.vcf.gz"
CATALOG="/projects/rohlfslab/shared/TR_catalogs/TR_catalog_normalized.bed"
CATALOG_SORTED="${IN_DIR_MAIN}/TR_catalog_normalized_sorted.bed"
MASTER_TR_DIR="${IN_DIR_MAIN}/master_tr"
MASTER_TR_FILE="${MASTER_TR_DIR}/${SAMPLE}.master_tr.bed"
MATRIX_TEMP_DIR="${IN_DIR_MAIN}/matrix_temp"
MATRIX_FINAL_DIR="${IN_DIR_MAIN}/matrix_final"

mkdir -p ${BED_DIR}
mkdir -p ${R_DIR}
mkdir -p ${MASTER_TR_DIR}
mkdir -p ${MATRIX_TEMP_DIR}
mkdir -p ${MATRIX_FINAL_DIR}

SAMPLE_BED_FILE="${BED_DIR}/${SAMPLE}.bed"

conda deactivate
conda activate ds_env
./calculate_tr_repeat_lengths.py "$SAMPLE_SORTED_FILE" "$SAMPLE_R_FILE" "$SAMPLE" "False"
conda deactivate

conda activate longtr_venv
bcftools query -f "%CHROM\t%START\t%END\t[%R]\t[%HET]" "$SAMPLE_R_FILE" > "$SAMPLE_BED_FILE"

# fix TR catalog
if [[ ! -f "$CATALOG_SORTED" ]]; then
    echo "sorted catalog not in folder, creating now."
    sort -k1,1V -k2,2n -k3,3n "$CATALOG" > "$CATALOG_SORTED"
fi

bedtools intersect -a "$CATALOG_SORTED" -b "$SAMPLE_BED_FILE" -loj > "$MASTER_TR_FILE"

# keep files as tab seperated because this is what is compatible with datamash (to transpose the matrix/file)
awk -F'\t' 'BEGIN{ORS="\t"} {$9=($9=="." ? 0 : $9=="-1" ? "NA" : $9); print $9}' "$MASTER_TR_FILE" > "${MATRIX_TEMP_DIR}/${SAMPLE}.het.txt"
awk -F'\t' 'BEGIN{ORS="\t"} {print ($8=="-1" ? "NA" : $8)}' "$MASTER_TR_FILE" > "${MATRIX_TEMP_DIR}/${SAMPLE}.gt.txt"


for f in "${MATRIX_TEMP_DIR}"/*.gt.txt; do
    printf "%s," "$(basename "${f%.gt.txt}")"
    cat "$f"
    echo
done > "${MATRIX_FINAL_DIR}/all.gt.txt"

for f in "${MATRIX_TEMP_DIR}"/*.het.txt; do
    printf "%s," "$(basename "${f%.het.txt}")"
    cat "$f"
    echo
done > "${MATRIX_FINAL_DIR}/all.het.txt"
