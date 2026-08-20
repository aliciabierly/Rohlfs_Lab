#!/bin/bash

module load miniconda3
conda activate ds_env

TR_CATALOG="/scratch/rohlfslab/abierly2/LongTR/TR_catalog_normalized_sorted.bed"
awk 'BEGIN{ORS="\t"} {print $1"_"$2"_"$3"_"$4}' "$TR_CATALOG" > tr_temp.txt

python3 <<'PY'
scratch_dir="/scratch/rohlfslab/abierly2"

file1=f"{scratch_dir}/LongTR/matrix_temp/HG00096.gt.txt"
file2=f"{scratch_dir}/LongTR_gf/matrix_temp/HG00096.gt.txt"
file3="tr_temp.txt"

with open(file1) as f1, open(file2) as f2, open(file3) as f3:
    values1 = f1.readline().rstrip("\n").split("\t")
    values2 = f2.readline().rstrip("\n").split("\t")
    catalog = f3.readline().rstrip("\n").split("\t")

print("File 1:", len(values1))
print("File 2:", len(values2))
print("Catalog:", len(catalog))

differences = 0

for tr, v1, v2 in zip(catalog, values1, values2):
    if v1 != v2:
        differences += 1
        print(tr, repr(v1), repr(v2), sep="\t")

print("Number of differences:", differences)
PY
