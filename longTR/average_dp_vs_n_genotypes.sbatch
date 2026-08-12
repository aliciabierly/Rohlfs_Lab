#!/bin/bash
#SBATCH --job-name=average_dp_vs_n_genotypes
#SBATCH --mem=1G
#SBATCH --time=01:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/average_dp_vs_n_genotypes.out
#SBATCH --error=logs/average_dp_vs_n_genotypes.err   # Keep error files !

module load bcftools
module load miniconda3

INPUT_DIR="/scratch/rohlfslab/abierly2/LongTR/sorted_vcfs"
OUTPUT_DIR="/scratch/rohlfslab/abierly2/LongTR"
OUTPUT_FILE="${OUTPUT_DIR}/average_dp_vs_n_genotypes.csv"
PLOT_FILE="${OUTPUT_DIR}/average_dp_vs_n_genotypes.png"

# create header
touch "$OUTPUT_FILE"
echo "sample_name,n_genotypes,average_dp" > "$OUTPUT_FILE"

# input data
for f in "${INPUT_DIR}"/*.gz; do
    sample_name=$(basename "$f" .sorted.vcf.gz)
    bcftools query -f '[%DP]' "$f" |
    awk -v sample="$sample_name" ' {
            sum += $1
            n++
        }
        END {
            printf "%s,%d,%.4f\n", sample, n, sum/n
     } ' >> "$OUTPUT_FILE"
#    sample_name=$(basename "$f" .sorted.vcf.gz)
#    n_genotypes=$(bcftools view -H "$f" | wc -l)
#    average_dp=$(bcftools query -f '[%DP]' "$f" | awk '{sum += $1; n++} END {if (n > 0) print sum/n}')
#    printf "%s,%s,%s\n" "$sample_name" "$n_genotypes" "$average_dp"
done >> "$OUTPUT_FILE"

conda activate ds_env
python3 << EOF
import pandas as pd
import matplotlib.pyplot as plt
df = pd.read_csv("$OUTPUT_FILE")

plt.figure(figsize=(10, 6))
plt.scatter(df["average_dp"], df["n_genotypes"])
plt.xlabel("Average depth per Sample")
plt.ylabel("Number of Genotyped TRs")
plt.savefig("$PLOT_FILE", dpi=300)
EOF
conda deactivate
