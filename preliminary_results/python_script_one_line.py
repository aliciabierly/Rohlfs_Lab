import sys
import numpy as np

def pull_out_alleles(val):
    val = val.strip().strip("'\"")
    al1, al2 = val.split("|")
    al1, al2 = float(al1), float(al2)
    return al1, al2

line = sys.argv[1]

catalog_line, TR_line, archaic_line = line.split(",", 2)
catalog_l = catalog_line.strip().strip("'\"").split("\t")
TR_l = TR_line.strip().strip("'\"").split("\t")
archaic_l = archaic_line.strip().strip("'\"").split("\t")
#print(catalog_l)
#print(TR_l)
#print(archaic_l)
chr, start, end, motif = catalog_l
# create empty lists to store the allele lengths for each bin
# 0 and 1 = binary for how many alleles intogressed
# 00 = no intogression at TR, 01=1 allele intogressed, 11=2 alleles introgressed
homo_00, het_01, homo_11 = [], [], []
ctr = 0

for i in range(len(TR_l)): # run through each sample
    tr, archaic = TR_l[i], archaic_l[i]
    if tr == ".": # if TR is not genotyped, skip rest of loop
        continue
    tr_al1, tr_al2 = pull_out_alleles(tr)
    archaic = archaic.strip().strip("'\"")
    if archaic == "0|0":
        homo_00.append(tr_al1)
        homo_00.append(tr_al2)
    elif archaic == "0|1" or archaic == "1|0":
        het_01.append(tr_al1)
        het_01.append(tr_al2)
    elif archaic == "1|1":
        homo_11.append(tr_al1)
        homo_11.append(tr_al2)
    ctr+=1

homo_00_mean = np.mean(homo_00) if homo_00 else np.nan
het_01_mean = np.mean(het_01) if het_01 else np.nan
homo_11_mean = np.mean(homo_11) if homo_11 else np.nan

homo_00_n = len(homo_00)//2
het_01_n = len(het_01)//2
homo_11_n = len(homo_11)//2

print(chr, start, end, motif, homo_00_mean, homo_00_n, het_01_mean, het_01_n, homo_11_mean, homo_11_n)
