#!/bin/bash
#SBATCH --job-name=het_monomer_calc_with_stutter
#SBATCH --mem=40G
#SBATCH --time=1-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/het_monomer_%A.out
#SBATCH --error=logs/het_monomer_%A.err   # Keep error files !

module load miniconda3
conda activate ds_env

IN_MAIN_DIR="/scratch/rohlfslab/abierly2/LongTR_gf"

CATALOG="${IN_MAIN_DIR}/TR_catalog_normalized_sorted.bed"
OUT_DIR="${IN_MAIN_DIR}/dimers"
MATRIX="${IN_MAIN_DIR}/matrix_final/all.gt.t.txt"
TEMP_DIR="${OUT_DIR}/temp"

mkdir -p "${TEMP_DIR}"

# Find monomers
awk 'length($NF) == 2 {print NR}' "$CATALOG" > "${TEMP_DIR}/indexes.txt"

# Create final file with header
{
    printf "chr\tstart\tend\tmotif\t"
    head -n 1 "$MATRIX"

    paste \
        <(awk 'NR==FNR {wanted[$1]; next} FNR in wanted' \
            "${TEMP_DIR}/indexes.txt" "$CATALOG") \
        <(awk 'NR==FNR {wanted[$1+1]; next} FNR in wanted' \
            "${TEMP_DIR}/indexes.txt" "$MATRIX")
} > "${OUT_DIR}/subset_matrix.txt"

python3 <<'PY'

import pandas as pd
import numpy as np

def calculate_het(row):
    '''this takes in one row from the matrix and caculates the loci heterozygousity and number of genotyped TRs'''
    total, het = 0, 0
    for i in range(4, len(row)):
        if row[i] != ".":
            al1, al2 = row[i].split("|")
            al1, al2 = float(al1), float(al2)
            total+=1
            if np.abs(al1 - al2) > 1:
                het += 1
    if total > 0:
        return pd.Series([total, het/total])
    return pd.Series([0, np.nan])

df = pd.read_csv("/scratch/rohlfslab/abierly2/LongTR_gf/dimers/subset_matrix.txt", sep="\t")
df[["n", "het"]] = df.apply(calculate_het, axis=1)

df_het=df[["chr", "start", "end", "motif", "n", "het"]]

df_het.to_csv("/scratch/rohlfslab/abierly2/LongTR_gf/dimers/het.txt")

plt.hist(df_het[df_het["n"] > 0]["het"])

plt.savefig("/scratch/rohlfslab/abierly2/LongTR_gf/dimers/het.png",
            dpi=300,
            bbox_inches="tight")
plt.close()

PY
