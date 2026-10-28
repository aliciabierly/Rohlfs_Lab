#!/bin/bash
#SBATCH --job-name=index_file
#SBATCH --mem=5G
#SBATCH --time=5:00:00
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --partition=compute
#SBATCH --array=1-11
#SBATCH --account=rohlfslab
#SBATCH --output=logs/index_%A_%a.out
#SBATCH --error=logs/index_%A_%a.err

module load bcftools
module load miniconda3
module load bedtools
module load parallel
module load vcftools

OUTDIR="/scratch/rohlfslab/abierly2/hmmix_genome_mask"
SAMPLE_JSON="${OUTDIR}/individuals.json"
GENOME_BED="${OUTDIR}/all_genome.bed"

CHR_N1=$((SLURM_ARRAY_TASK_ID*2-1))
CHR_N2=$((SLURM_ARRAY_TASK_ID*2))

echo "${CHR_N1} and ${CHR_N2}"
CHR_FILE1="${OUTDIR}/chr${CHR_N1}.bcf"
CHR_FILE2="${OUTDIR}/chr${CHR_N2}.bcf"
OUTGROUP="${OUTDIR}/tmp/outgroup_chr${CHR_N1}_chr${CHR_N2}.txt"
MUTATIONRATE="${OUTDIR}/tmp/mutationrate_chr${CHR_N1}_chr${CHR_N2}.bed"

hmmix create_outgroup -ind=$SAMPLE_JSON -vcf=$CHR_FILE1,$CHR_FILE2 -weights=$GENOME_BED -out=$OUTGROUP
hmmix mutation_rate -outgroup=$OUTGROUP -weights=$GENOME_BED -window=1000000 -out=$MUTATIONRATE
cd "${OUTDIR}/tmp"
hmmix create_ingroup  -ind=$SAMPLE_JSON -vcf=$CHR_FILE1,$CHR_FILE2 -weights=$GENOME_SUB -out="obs_chr${CHR_N1}_chr${CHR_N2}" -outgroup=$OUTGROUP
