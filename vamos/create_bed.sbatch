#!/bin/bash
#SBATCH --job-name=vamos_bedfile
#SBATCH --mem=20G
#SBATCH --time=1-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --array=1-711%50                # only 35 running at once
#SBATCH --output=logs/longtr_bedfile_%A_%a.out
#SBATCH --error=logs/longtr_bedfile%A_%a.err   # Keep error files !
# this file creates a bedfile of the TR length information, converts to lengths to 
# num of repeating motifs, and filters out TRs that are <2.5 repeats long.

module load miniconda3/20240410
# source $(conda info --base)/etc/profile.d/conda.sh
# virtual env I created that has longtr installed on it
# instructions for longTR installation are on longTR github
module load samtools
module load parallel/20241222
module load bcftools
module load bedtools
conda activate longtr_venv
### PATHS
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/shared/hannah_alicia_shared_sampleIDs.txt)
echo "Processing sample: $SAMPLE"

SCRATCH="/scratch/rohlfslab/abierly2"
IN_DIR_MAIN="${SCRATCH}/vamos"
IN_DIR="${IN_DIR_MAIN}/sorted_vcfs"
BED_DIR="${IN_DIR_MAIN}/bedfiles"
SAMPLE_SORTED_FILE="${IN_DIR}/${SAMPLE}.sorted.vcf.gz"
SAMPLE_SORTED_AUTOSOME_FILE="${IN_DIR}/${SAMPLE}.autosome.vcf.gz"
SAMPLE_SORTED_AUTOSOME_NO_DEL_FILE="${IN_DIR}/${SAMPLE}.autosome.no_del.vcf.gz"
CATALOG="/projects/rohlfslab/shared/TR_catalogs/TR_catalog_normalized.bed"
CATALOG_SORTED="${IN_DIR_MAIN}/TR_catalog_normalized_sorted.bed"
MASTER_TR_DIR="${IN_DIR_MAIN}/master_tr"
MASTER_TR_FILE="${MASTER_TR_DIR}/${SAMPLE}.master_tr.bed"
MATRIX_TEMP_DIR="${IN_DIR_MAIN}/matrix_temp"
MATRIX_FINAL_DIR="${IN_DIR_MAIN}/matrix_final"

mkdir -p ${BED_DIR}
mkdir -p ${MASTER_TR_DIR}
mkdir -p ${MATRIX_TEMP_DIR}
mkdir -p ${MATRIX_FINAL_DIR}

SAMPLE_BED_FILE="${BED_DIR}/${SAMPLE}.bed"

# only autosomes included in this study!
# TRs must be at least 2.5 repeats long
bcftools view \
    -r chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22 \
    -i 'INFO/LEN_H1>=2.5 && INFO/LEN_H2>=2.5' \
    -Oz \
    -o "$SAMPLE_SORTED_AUTOSOME_NO_DEL_FILE" \
    "$SAMPLE_SORTED_FILE"

tabix -f -p vcf "$SAMPLE_SORTED_AUTOSOME_NO_DEL_FILE"

bcftools query -f "%CHROM\t%POS\t[%END]\t[%RS\t%GT]" "$SAMPLE_SORTED_AUTOSOME_NO_DEL_FILE" > "$SAMPLE_BED_FILE"

# fix TR catalog
if [[ ! -f "$CATALOG_SORTED" ]]; then
    echo "sorted catalog not in folder, creating now."
    awk '$1 ~ /^chr([1-9]|1[0-9]|2[0-2])$/' "$CATALOG" |
        sort -k1,1V -k2,2n -k3,3n > "$CATALOG_SORTED"
fi

bedtools intersect -a "$CATALOG_SORTED" -b "$SAMPLE_BED_FILE" -loj > "$MASTER_TR_FILE"

# Create individual sample files if they don't already exist
awk -F'\t' 'BEGIN{ORS="\t"} {$9=($9=="." ? 0 : $9=="-1" ? "NA" : $9); print $9}' \
    "$MASTER_TR_FILE" > "${MATRIX_TEMP_DIR}/${SAMPLE}.het.txt"
awk -F'\t' 'BEGIN{ORS="\t"} {print ($8=="-1" ? "NA" : $8)}' \
    "$MASTER_TR_FILE" > "${MATRIX_TEMP_DIR}/${SAMPLE}.gt.txt"

conda deactivate
