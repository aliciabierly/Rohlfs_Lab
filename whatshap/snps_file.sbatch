#!/bin/bash
#SBATCH --job-name=index_file
#SBATCH --mem=20G
#SBATCH --time=10:00:00
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/index_%A_%a.out
#SBATCH --error=logs/index_%A_%a.err

module load bcftools
module load miniconda3
conda activate longtr_env
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt)
echo "Processing sample: $SAMPLE"

SNP_INDEL_FILE="1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz"
FILTERED_SNP_INDEL_FILE="filtered.1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz"

# download file
wget "https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/variants/1000_Genomes_Project/chm13v2.0/Phased_SHAPEIT5_v1.1/1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz"
bcftools index "1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz"

# filter file for only ind included in study
bcftools view -S $SAMPLE_FILE $SNP_INDEL_FILE -Oz -o "$FILTERED_SNP_INDEL_FILE"
tabix -p vcf $FILTERED_SNP_INDEL_FILE
