#!/bin/bash
#SBATCH --job-name=hetero
#SBATCH --mem=20G
#SBATCH --time=1:00:00                 # increased time for reliability
#SBATCH --cpus-per-task=24
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/hetero.out
#SBATCH --error=logs/hetero.err   # Keep error files !

#module load miniconda3
source $(conda info --base)/etc/profile.d/conda.sh
conda activate ds_env
python make_heterozygousity.py
