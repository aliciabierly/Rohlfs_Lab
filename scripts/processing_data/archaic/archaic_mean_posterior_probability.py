# this script was created to look at the differences in the ND_type and how many rows are eliminated with 
# constraints on the mean_prob or mean posterior probability of each archaic tract.
# threholds need to be at least above 0.8. 

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#Directories
OUT_DIR="/scrach/rohlfslab/abierly/archaic_tract_exploration"

# Sample data
headers = "chrom start   end sample  haplotype   pop	region	mean_prob	ND_type	snps	admixpopvariants	Altai	Vindija	Denisova	Chagyrskaya	variants"
headers = headers.strip().split()
df = pd.read_csv("sand_t2t_coordinates_mapped.tsv", sep="\t", header=None)
df.columns = headers

# filter and save new datasets with each threhold
def transform_df(df, threshold):
    "threshold: based on mean_prob; mean_prob >= threshold"
    df_transform = df[df["mean_prob"] >= threshold]
    print(f"Threshold of {threshold} contains {df_transform.shape[1]} rows.")
    df_transform.to_csv(f"{OUT_DIR}/threshold_{threshold}.csv")
    return df_transform

# create for loop with all threholds
threholds = [0.8, 0.85, 0.9, 0.95]
ND_types=df.sort_values(by="ND_type")["ND_type"].unique()
summary = pd.DataFrame(columns=threholds, index=ND_types)

for i in threholds:
    df_transformed = transform_df(df, i)
    summary[i] = df_transformed.sort_values(by="ND_type")["ND_type"].value_counts()
  
print(summary)

