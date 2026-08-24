#!/bin/bash
#SBATCH --job-name=calculate_n_deletions
#SBATCH --mem=32G
#SBATCH --cpus-per-task=2
#SBATCH --time=6:00:00
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/deletions_%A.out
#SBATCH --error=logs/deletions_%A.err
#SBATCH --array=1-711%50
#SBATCH --ntasks=1

module load bcftools
module load miniconda3
SPECIFIC_DIR="LongTR_gf"
INPUT_DIR="/scratch/rohlfslab/abierly2/${SPECIFIC_DIR}/sorted_vcfs"
OUTPUT_DIR="/scratch/rohlfslab/abierly2/${SPECIFIC_DIR}/deletions"
mkdir -p "${OUTPUT_DIR}"

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/shared/hannah_alicia_shared_sampleIDs.txt)
SAMPLE_FILE="${INPUT_DIR}/${SAMPLE}.autosome.vcf.gz"
echo "Processing sample: $SAMPLE"

bcftools view -H -i 'ALT="<DEL>"' "$SAMPLE_FILE" | \
    awk -v sample="$SAMPLE" '{print sample "\t" $0}' \
    > "${OUTPUT_DIR}/${SAMPLE}.deletions.txt"

#awk -F' ' '{print $1}' "${OUTPUT_DIR}/deletions.txt" | sort | uniq -c > "${OUTPUT_DIR}/deletions_group_sample.txt"

#awk -F' ' '{print $2, $3}' deletions.txt | sort | uniq -c > "${OUTPUT_DIR}/deletions_group_loci.txt"
