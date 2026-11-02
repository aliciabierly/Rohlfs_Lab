#!/bin/bash
#SBATCH --job-name=stats
#SBATCH --mem=32G
#SBATCH --time=10:00:00
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/stats_%a.out
#SBATCH --error=logs/stats_%a.err


module load miniconda3
conda activate whatshap_env
whatshap stats 1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz
