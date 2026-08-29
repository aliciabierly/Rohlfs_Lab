#!/bin/bash
#SBATCH --job-name=longtr_full_pipeline
#SBATCH --mem=10G
#SBATCH --time=6:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=computelong
#SBATCH --account=rohlfslab
#SBATCH --array=1-467%100                # only 35 running at once
#SBATCH --output=logs/longtr_%A_%a.out
#SBATCH --error=logs/longtr_%A_%a.err   # Keep error files !

module load miniconda3/20240410
module load samtools
module load parallel/20241222
module load bcftools

### PATHS
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt)
echo "Processing sample: $SAMPLE"

# Reference genome & TR catalog
SCRATCH="/scratch/rohlfslab/abierly2"
TR_BED="TRs_of_interest_noheader.bed"
OUTDIR_MAIN="${SCRATCH}/compare_changes_gf" ### MUST CHANGE
OUTFILE_NEG1="${OUTDIR_MAIN}/${SAMPLE}_neg1.txt"
OUTFILE_NEG10="${OUTDIR_MAIN}/${SAMPLE}_neg10.txt"
mkdir -p ${OUTDIR_MAIN}

#bcftools query -R $TR_BED -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO\t[%GT\t%ALLREADS\t%MALLREADS]\n' "${SCRATCH}/LongTR_gf/sorted_vcfs/${SAMPLE}.autosome.vcf.gz" > "$OUTFILE_NEG1"
bcftools query -R $TR_BED -f '%CHROM\t%POS\t%REF\t%ALT\t[%GT]\n' "${SCRATCH}/LongTR_gf/sorted_vcfs/${SAMPLE}.autosome.vcf.gz" > "$OUTFILE_NEG1"
bcftools query -R $TR_BED -f '%CHROM\t%POS\t%REF\t%ALT\t[%GT]\n' "${SCRATCH}/LongTR/sorted_vcfs/${SAMPLE}.autosome.vcf.gz" > "$OUTFILE_NEG10"
