#!/usr/bin/env python3
import sys
import pandas as pd
import numpy as np

chunks = []
chunksize = 10000
for chunk in pd.read_csv("cleaned_introgressed_1000KGdataset.txt", delimiter='\t', chunksize=chunksize):
    chunks.append(chunk)

df = pd.concat(chunks, ignore_index=True)
df_archaic = df[df["state"] == "Archaic"]
df_human = df[df["state"] == "Human"]

# checking no overlapping intervals per individual
no_overlap = False
for ind in df["ind_id"].unique(): # split by individual
    df_ind = df[df["ind_id"] == ind].sort_values(by="start")
    
    for chrom in df_ind["chrom"].unique()[0:2]: # split by chromosome
        df_ind_chrom = df_ind[df_ind["chrom"] == chrom]
        for hap in range(1, 3):
            df_ind_chrom_hap = df_ind_chrom[df_ind_chrom["haploid"] == hap].reset_index(drop=True)
            start = df_ind_chrom_hap["start"]
            end = df_ind_chrom_hap["end"]
            
            for i in range(1, df_ind_chrom_hap.shape[0]):
                prev_start, prev_end = start[i-1], end[i-1]
                curr_start, curr_end = start[i], end[i]
                if curr_start < prev_end:
                    no_overlap = False
                    print(f"ID: {ind}: overlap at {prev_start}-{prev_end}, {curr_start}-{curr_end}")
                    break
print("No overlapping intervals!")
