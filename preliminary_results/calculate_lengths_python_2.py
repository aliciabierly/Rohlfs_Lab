import sys
import numpy as np

def pull_out_alleles(val):
    val = val.strip().strip("'\"")
    al1, al2 = val.split("|")
    return float(al1), float(al2)


for line in sys.stdin:

    line = line.rstrip("\n")

    catalog_line, TR_line, archaic_line = line.split(",", 2)

    catalog_l = catalog_line.split("\t")
    TR_l = TR_line.split("\t")
    archaic_l = archaic_line.strip().strip("'\"").split("\t")

    chr, start, end, motif = catalog_l

    homo_00_sum = 0
    homo_00_n = 0

    het_01_sum = 0
    het_01_n = 0

    homo_11_sum = 0
    homo_11_n = 0

    for tr, archaic in zip(TR_l, archaic_l):

        if tr == ".":
            continue

        tr_al1, tr_al2 = pull_out_alleles(tr)

        archaic = archaic.strip().strip("'\"")

        if archaic == "0|0":
            homo_00_sum += tr_al1 + tr_al2
            homo_00_n += 1

        elif archaic == "0|1" or archaic == "1|0":
            het_01_sum += tr_al1 + tr_al2
            het_01_n += 1

        elif archaic == "1|1":
            homo_11_sum += tr_al1 + tr_al2
            homo_11_n += 1

    homo_00_mean = (
        homo_00_sum / (2 * homo_00_n)
        if homo_00_n else np.nan
    )

    het_01_mean = (
        het_01_sum / (2 * het_01_n)
        if het_01_n else np.nan
    )

    homo_11_mean = (
        homo_11_sum / (2 * homo_11_n)
        if homo_11_n else np.nan
    )

    print(
        chr, start, end, motif,
        homo_00_mean, homo_00_n,
        het_01_mean, het_01_n,
        homo_11_mean, homo_11_n
    )
