#!/bin/bash

#SBATCH --job-name=het_monomer_calc
#SBATCH --mem=8G
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/het_monomer_%A.out
#SBATCH --error=logs/het_monomer_%A.err

module load miniconda3
conda activate ds_env

IN_MAIN_DIR="/scratch/rohlfslab/abierly2/LongTR_gf"

CATALOG="${IN_MAIN_DIR}/TR_catalog_normalized_sorted.bed"
MATRIX="${IN_MAIN_DIR}/matrix_final/all.gt.t.txt"

OUT_DIR="${IN_MAIN_DIR}/monomers_new"
TEMP_DIR="${OUT_DIR}/temp"

mkdir -p "${OUT_DIR}" "${TEMP_DIR}"

# Find monomer loci
awk 'length($NF) == 1 {print NR}' \
    "${CATALOG}" > "${TEMP_DIR}/indexes.txt"

# Create subset matrix
{
    printf "chr\tstart\tend\tmotif\t"
    head -n 1 "${MATRIX}"

    paste \
        <(awk 'NR==FNR {wanted[$1]; next} FNR in wanted' \
            "${TEMP_DIR}/indexes.txt" "${CATALOG}") \
        <(awk 'NR==FNR {wanted[$1+1]; next} FNR in wanted' \
            "${TEMP_DIR}/indexes.txt" "${MATRIX}")
} > "${OUT_DIR}/subset_matrix.txt"

# Calculate heterozygosity
python3 <<'PY'

import matplotlib.pyplot as plt

MATRIX = "/scratch/rohlfslab/abierly2/LongTR_gf/monomers_new/subset_matrix.txt"
OUT = "/scratch/rohlfslab/abierly2/LongTR_gf/monomers_new/het.txt"
PLOT = "/scratch/rohlfslab/abierly2/LongTR_gf/monomers_new/het.png"

het_values = []

with open(MATRIX) as infile, open(OUT, "w") as outfile:

    # Skip matrix header
    header = infile.readline().rstrip("\n").split("\t")

    outfile.write("chr\tstart\tend\tmotif\tn\thet\n")

    for line in infile:

        fields = line.rstrip("\n").split("\t")

        # First four columns
        chrom = fields[0]
        start = fields[1]
        end = fields[2]
        motif = fields[3]

        total = 0
        het = 0

        # Genotypes start at column 5
        for genotype in fields[4:]:

            if genotype == ".":
                continue

            try:
                al1, al2 = genotype.split("|")
                al1 = float(al1)
                al2 = float(al2)
            except (ValueError, TypeError):
                continue

            total += 1

            if abs(al1 - al2) > 1:
                het += 1

        if total > 0:
            h = het / total
            het_values.append(h)
            outfile.write(f"{chrom}\t{start}\t{end}\t{motif}\t{total}\t{h}\n")
        else:
            outfile.write(f"{chrom}\t{start}\t{end}\t{motif}\t0\tNaN\n")


# --------------------------------------------------
# Histogram
# --------------------------------------------------

plt.hist(het_values)

plt.xlabel("Heterozygosity")
plt.ylabel("Number of loci")

plt.savefig(
    PLOT,
    dpi=300,
    bbox_inches="tight"
)

plt.close()

PY

echo "Finished."
echo "Output: ${OUT_DIR}/het.txt"
echo "Plot:   ${OUT_DIR}/het.png"

PY
