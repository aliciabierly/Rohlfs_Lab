import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import sys

SPECIFIC_DIR = sys.argv[1]
file_path = sys.argv[2]
df = pd.read_csv(file_path, sep="\t", header=None)
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Number of deletions per sample
df_sub=df.value_counts(0).reset_index()
mean=np.mean(df_sub["count"])
axes[0].hist(df_sub["count"], bins=np.arange(0, 20000, 500))
axes[0].axvline(mean, label=f"mean: {np.round(mean)}", color="r")
axes[0].set_xlabel("Number of Deletions")
axes[0].set_ylabel("Count")
axes[0].set_title(f"Number of Deletions per Sample (n={df_sub.shape[0]})")

# Frequency of deletions per loci
df_sub=df.value_counts([1, 2]).reset_index()
mean=np.mean(df_sub["count"])
axes[1].hist(df_sub["count"], bins=np.arange(0, 20))
axes[1].axvline(mean, label=f"mean: {np.round(mean)}", color="r")
axes[1].set_xlabel("Number of Deletions")
axes[1].set_ylabel("Count")
axes[1].set_title(f"Frequency of Deletions per Loci (n={df_sub.shape[0]})")

fig.suptitle(SPECIFIC_DIR)
plt.tight_layout()
plt.savefig(
    f"/scratch/rohlfslab/abierly2/{SPECIFIC_DIR}/deletions/plots.png",
    dpi=300,
    bbox_inches="tight"
)
plt.show()
