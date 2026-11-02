#!/bin/bash
#SBATCH --job-name=index_file
#SBATCH --mem=20G
#SBATCH --time=10:00:00
#SBATCH --cpus-per-task=22
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --partition=compute
#SBATCH --array=1-22
#SBATCH --account=rohlfslab
#SBATCH --output=logs/index_%A_%a.out
#SBATCH --error=logs/index_%A_%a.err

module load bcftools
module load miniconda3
module load bedtools
conda activate longtr_venv
SAMPLE_FILE="/projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt"

SNP_INDEL_FILE="1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz"
FILTERED_SNP_INDEL_FILE="filtered.1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz"

# download file
wget "https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/variants/1000_Genomes_Project/chm13v2.0/Phased_SHAPEIT5_v1.1/1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz"
bcftools index "1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz"

# filter file for only ind included in study
# run by chromosome as array/in parallel
# index each file
bcftools view -S $SAMPLE_FILE -r "chr${SLURM_ARRAY_TASK_ID}" filtered.1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz -Ou --force-samples | \
    bcftools +fill-tags --write-index -Oz -o "filtered_recalibrated.${SLURM_ARRAY_TASK_ID}.vcf.gz" -- -t AC,AN,AF,MAF,AC_Het,AC_Hom

# merge all files
bcftools concat filtered_recalibrated.{1..22}.vcf.gz -Oz -o merged_calibrated.vcf.gz
bcftools index -t merged_calibrated.vcf.gz

#rm filtered_recalibrated*

# find out heterozygousity per loci over entire genome
#for f in filtered_recalibrated.*.vcf.gz; do bcftools query -f '%AC_Het' "$f" | awk '{n=0; split($0, a, ","); for(i in a) n+=a[i]; print n}'; done | sort | uniq -c > heterozygous_snps_per_loci.txt

bcftools query -f '[%GT\t]' "filtered_recalibrated.${SLURM_ARRAY_TASK_ID}.vcf.gz" | awk '{
    het=0
    for (i=1; i<=(NF-1); i++) {
        split($i, gt, "|")
        if (gt[1] != "." && gt[2] != "." && gt[1] != gt[2])
            het++
    }
    print het
}' | sort | uniq -c > "het.${SLURM_ARRAY_TASK_ID}.txt" #; done | sort | uniq -c > het_real.txt

# make bedtools window
# pull out CHR and posiiton with AC_het>0
# need to figure out how to pull out contig values for each chrom from bcf -- in header
#bedtools makewindows -g ____ > windows.${SLURM_ARRAY_TASK_ID}.bed
#bcftools query -i "AC_Het>0" -f '%CHROM\t%POS' | bedtools intersect -a windows.${SLURM_ARRAY_TASK_ID}.bed -b - -c > snp_counts.${SLURM_ARRAY_TASK_ID}.bed
# bedtools intersect of two files
# merge all files after
