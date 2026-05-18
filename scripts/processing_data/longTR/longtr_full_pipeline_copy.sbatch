#!/bin/bash
#SBATCH --job-name=longtr_full_pipeline
#SBATCH --mem=48G
#SBATCH --time=2-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=24
#SBATCH --ntasks=1
#SBATCH --partition=computelong
#SBATCH --account=rohlfslab
#SBATCH --array=1-663%35                # only 35 running at once
#SBATCH --output=logs/longtr_%A_%a.out
#SBATCH --error=logs/longtr_%A_%a.err   # Keep error files !

echo "LongTR full pipeline starting"
date

# MODULES
module load miniconda3/20240410
# source $(conda info --base)/etc/profile.d/conda.sh
# virtual env I created that has longtr installed on it
# instructions for longTR installation are on longTR github
conda activate longtr_venv
module load samtools
module load parallel/20241222
module load bcftools

### PATHS
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/shared/hannah_alicia_shared_sampleIDs.txt)
echo "Processing sample: $SAMPLE"

# Reference genome & TR catalog
REF_DIR="/projects/rohlfslab/shared/reference_genomes"
REF="${REF_DIR}/1KG_ONT_VIENNA_t2t_REFERENCE.fa"
#CATALOG_DIR="/projects/rohlfslab/shared/TR_catalogs"
#CATALOG="${CATALOG_DIR}/TR_catalog_normalized.bed"
CATALOG="$/~/winter/week3/TR_homo_mucin_catalog_normalized.bed"

# Output directories
mkdir -p "scratch/rohlfslab/abierly2/mucin"  #"/scratch/rohlfslab/undergrad_data"
# OUTDIR="/scratch/rohlfslab/undergrad_data/longTR_pipeline_${SAMPLE}"
MERGED_DIR="/scratch/rohlfslab/merged_vcfs"
mkdir -p ${OUTDIR}
mkdir -p ${MERGED_DIR}

MERGED_VCF="${MERGED_DIR}/${SAMPLE}.merged.vcf.gz"
MERGED_TBI="${MERGED_DIR}/${SAMPLE}.merged.vcf.gz.tbi"

# CHECK 1: Is the final merged VCF complete?
if [ -f "$MERGED_VCF" ] && [ -f "$MERGED_TBI" ]; then
    echo "Sample $SAMPLE already has complete merged VCF with index. Skipping entirely."
    exit 0
fi

# CHECK 2: Do all per-chromosome VCFs already exist and are indexed?
# Create chromosome list
cut -f1 $CATALOG | sort -u > ${OUTDIR}/chrom_list.txt

ALL_CHROM_VCFS_EXIST=true
while read CHR; do
    VCF="${OUTDIR}/${SAMPLE}.${CHR}.vcf.gz"
    TBI="${VCF}.tbi"
    if [ ! -f "$VCF" ] || [ ! -f "$TBI" ]; then
        ALL_CHROM_VCFS_EXIST=false
        echo "Missing or unindexed: $VCF"
        break
    fi
done < ${OUTDIR}/chrom_list.txt

# If all chromosome VCFs exist, skip genotyping and go straight to merging
if [ "$ALL_CHROM_VCFS_EXIST" = true ]; then
    echo "All per-chromosome VCFs exist for $SAMPLE. Skipping to merge step."
else
    echo "Some per-chromosome VCFs missing. Running genotyping..."
    
    # Download CRAM + CRAI
    SAMPLE_URL="https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1KG_ONT_VIENNA/t2t/${SAMPLE}.t2t.cram"
    CRAM="${SAMPLE}.cram"
    
    echo "Downloading CRAM for $SAMPLE..."
    wget -q ${SAMPLE_URL} -O ${CRAM}
    wget -q ${SAMPLE_URL}.crai -O ${CRAM}.crai
    
    export REF CRAM SAMPLE OUTDIR CATALOG_DIR
    
    ### PARALLEL GENOTYPING PER CHROMOSOME
    cat ${OUTDIR}/chrom_list.txt | \
    parallel -j ${SLURM_CPUS_PER_TASK} "
        CHR={}
        VCF_OUT=${OUTDIR}/${SAMPLE}.\${CHR}.vcf.gz
        
        # Skip if this chromosome VCF already exists and is indexed
        if [ -f \"\${VCF_OUT}\" ] && [ -f \"\${VCF_OUT}.tbi\" ]; then
            echo \"Chromosome \${CHR} VCF already exists and indexed. Skipping.\"
            exit 0
        fi
        
        echo \"Processing chromosome \${CHR}...\"
        
        # Temp BAM with quality scores
        TEMP_BAM=${OUTDIR}/${SAMPLE}.\${CHR}.withqual.bam
        
        samtools view -h --reference $REF $CRAM \$CHR | \
        awk '
        BEGIN {OFS=\"\t\"}
        /^@/ {print; next}
        {
            seq=\$10; qual=\$11
            if (seq == \"*\") { \$11=\"*\"; print; next }
            if (qual == \"*\") {
                newq=\"\"
                seqlen=length(seq)
                for(i=1; i<=seqlen; i++) newq = newq \"0\"
                \$11 = newq
            }
            print
        }' | \
        samtools view -b --reference $REF -o \$TEMP_BAM -
        
        samtools index \$TEMP_BAM
        

        # LongTR genotyping
        BED=${CATALOG_DIR}/TR_catalog_\${CHR}.bed
        
        LongTR \
            --bams \$TEMP_BAM \
            --fasta $REF \
            --regions \$BED \
            --tr-vcf \${VCF_OUT} \
            --min-mean-qual 0 \
	    --log /dev/null  # Discard LongTR verbose logs
        
        # Index the VCF
        tabix -p vcf \${VCF_OUT}
        
        # Clean up intermediate BAM
        rm -f \$TEMP_BAM \$TEMP_BAM.bai
        
        echo \"Chromosome \${CHR} complete.\"
    "
    
    # Clean up downloaded CRAM
    rm -f ${CRAM} ${CRAM}.crai
    
    echo "Genotyping complete for $SAMPLE"
fi



### MERGE STEP
echo "Starting merge for $SAMPLE..."

# Verify all chromosome VCFs exist before merging
MISSING_VCFS=false
while read CHR; do
    VCF="${OUTDIR}/${SAMPLE}.${CHR}.vcf.gz"
    if [ ! -f "$VCF" ]; then
        echo "ERROR: Missing VCF for chromosome $CHR. Cannot merge."
        MISSING_VCFS=true
    fi
done < ${OUTDIR}/chrom_list.txt

if [ "$MISSING_VCFS" = true ]; then
    echo "ERROR: Cannot merge $SAMPLE due to missing chromosome VCFs."
    exit 1
fi


# Perform the merge
echo "Concatenating chromosome VCFs for $SAMPLE..."
bcftools concat ${OUTDIR}/${SAMPLE}.chr*.vcf.gz -Oz -o ${MERGED_VCF}

# Index the merged VCF
echo "Indexing merged VCF for $SAMPLE..."
tabix -p vcf ${MERGED_VCF}



echo "Pipeline complete for $SAMPLE!"
date
