#!/bin/bash
#SBATCH --job-name=filter_longtr
#SBATCH --mem=32G
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --array=1-711%50
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/filter_longtr_%A_%a.out
#SBATCH --error=logs/filter_longtr_%A_%a.err
# File created by Hannah Siegel

module load miniconda3/20240410
# source $(conda info --base)/etc/profile.d/conda.sh
# virtual env I created that has longtr installed on it
# instructions for longTR installation are on longTR github
conda activate whatshap_env
module load samtools
module load parallel/20241222
module load bcftools

VARIANT_FILE="1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz"
REF_DIR="/projects/rohlfslab/shared/reference_genomes"
SCRATCH="/scratch/rohlfslab/abierly2"
REF="${REF_DIR}/1KG_ONT_VIENNA_t2t_REFERENCE.fa"
CATALOG_DIR="/projects/rohlfslab/shared/TR_catalogs"
CATALOG="${CATALOG_DIR}/TR_catalog_normalized.bed"
OUTDIR_CRAM="${SCRATCH}/crams"
CRAM="${OUTDIR_CRAM}/${SAMPLE}.t2t.cram"
CRAI="${CRAM}.crai"
BAM="/scratch/rohlfslab/abierly2/bams/${SAMPLE}.t2t.bam"
OUTDIR="/scratch/rohlfslab/abierly2/whatshap"
PHASED_VCF="${OUTDIR}/phased_vcfs/${SAMPLE}.phased.vcf"

mkdir -p "/scratch/rohlfslab/abierly2/whatshap/phased_vcfs"

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt)
echo "Processing sample: $SAMPLE"

# make the phased VCF of just variants for the particular sample
bcftools view \
    -s $SAMPLE \
    $VARIANT_FILE \
    -Oz \
    -o $PHASED_VCF
bcftools index $PHASED_VCF

whatshap haplotag \
    --reference $REF \
    $PHASED_VCF \
    $BAM \
    -o "${OUTDIR}/${SAMPLE}.haplotagged.bam"
samtools index "${OUTDIR}/${SAMPLE}.haplotagged.bam"
