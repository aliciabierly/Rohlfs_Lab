import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import sys

SPECIFIC_DIR = sys.argv[1]
file_path = sys.argv[2]
depth_file="/projects/rohlfslab/abierly2/Rohlfs_Lab/data/average_depth_by_sample.txt"
df_genotypes = pd.read_csv(file_path, sep="\t", header=None)
df_genotypes.columns=["sample", "n"]
df_dp=pd.read_csv(depth_file, sep="\t", header=None)
df_dp.columns=["sample", "dp"]

df_merged=df_genotypes.merge(df_dp, how="outer", on="sample")
df_merged["dp"] = df_merged["dp"].apply(float)
df_merged["n"] = df_merged["n"].apply(float)

print("DP>=14")
print(df_merged[df_merged["dp"]>=14].shape[0])
print(df_merged[df_merged["dp"]>=14]["n"].min())

plt.scatter(df_merged["dp"], df_merged["n"], alpha=0.5)
plt.xlabel("Average Depth")
plt.ylabel("Number of TRs Genotyped")
plt.title(f"{SPECIFIC_DIR}: N Genotyped TRs vs Average Depth over Autosomes (deletions removed)")
plt.savefig(
    f"/scratch/rohlfslab/abierly2/{SPECIFIC_DIR}/n_genotypes/plots.png",
    dpi=300,
    bbox_inches="tight"
)
plt.show()
