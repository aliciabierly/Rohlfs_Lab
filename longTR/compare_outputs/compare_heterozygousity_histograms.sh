#!/bin/bash

module load miniconda3
conda activate ds_env
python3 <<'PY'

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


longtr_runs=["LongTR", "LongTR_indel2", "LongTR_gf", "LongTR_new_parameters"] # provided file within scratch to pull files from
df=pd.read_csv(f"/scratch/rohlfslab/abierly2/{longtr_runs[0]}/matrix_final/het.txt", sep="\t")
print(df.head())
df["motif_len"] = df["motif"].apply(len)
df=df.rename(columns={"het": f"het_{longtr_runs[0]}", "n": f"n_{longtr_runs[0]}"})
df=df[~df["chr"].isin(["chrX", "chrY", "chrM"])]
for i in range(1, len(longtr_runs)):
    df_sub=pd.read_csv(f"/scratch/rohlfslab/abierly2/{longtr_runs[i]}/matrix_final/het.txt", sep="\t")
    df_sub=df_sub[~df_sub["chr"].isin(["chrX", "chrY", "chrM"])]
    df_sub=df_sub[df_sub["n"]>0]
    df_sub=df_sub.rename(columns={"het": f"het_{longtr_runs[i]}", "n": f"n_{longtr_runs[i]}"})
    df=pd.merge(df, df_sub, on=["chr", "start", "end", "motif"], how="outer")

df.to_csv("heterozygousity.txt")

het_cols = [col for col in df.columns if col.startswith("het_")]

print("Runs found:")

fig, axes = plt.subplots(
    nrows=2,
    ncols=3,
    figsize=(15, 8),
    sharex=True
)

bins = np.linspace(0, 1, 51)

runs = {
    "LongTR": "het_LongTR",
    "LongTR_indel2": "het_LongTR_indel2",
    "LongTR_gf": "het_LongTR_gf", 
    "LongTR_new_parameters": "het_LongTR_new_parameters"
}

for i, ax in enumerate(axes.flat, start=1):

    for run_name, column in runs.items():

        df_sub = df[df["motif_len"] == i]

        ax.hist(
            df_sub[column].dropna(),
            bins=bins,
            alpha=0.5,
            label=run_name
        )

    ax.set_title(f"Motif length = {i}", fontsize=14)
    ax.set_xlabel("Heterozygosity")
    ax.set_ylabel("Number of TRs")
    ax.set_xlim(0, 1)

# Only show legend once
axes[0, 0].legend(
    title="LongTR run",
    fontsize=10
)

fig.suptitle(
    "Heterozygosity Across LongTR Runs by Motif Length",
    fontsize=18
)

plt.tight_layout()

plt.savefig(
    "all_runs_heterozygosity_overlap.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()

PY
