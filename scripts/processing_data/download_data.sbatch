#!/bin/bash
#SBATCH --job-name=download_data
#SBATCH --mem=4G
#SBATCH --time=1-00:0:00                 # increased time for reliability
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --array=1-771%50                # only 35 running at once
#SBATCH --output=logs/download_%A_%a.out
#SBATCH --error=logs/download_%A_%a.err   # Keep error files !


SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /projects/rohlfslab/shared/hannah_alicia_shared_sampleIDs.txt)
echo "Download sample: $SAMPLE"

# Reference genome
REF_DIR="/projects/rohlfslab/shared/reference_genomes"
REF="${REF_DIR}/1KG_ONT_VIENNA_t2t_REFERENCE.fa"

# Output directory
OUT_DIR="/scratch/rohlfslab/abierly2/crams"
mkdir -p "${OUT_DIR}"

# Files
CRAM="${OUT_DIR}/${SAMPLE}.t2t.cram"
CRAI="${CRAM}.crai"

# URL
BASE_URL="https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1KG_ONT_VIENNA/t2t"
SAMPLE_URL="${BASE_URL}/${SAMPLE}.t2t.cram"

# Check + download CRAM
if [ -f "${CRAM}" ]; then
    echo "CRAM already exists: ${CRAM} — skipping download"
else
    echo "Downloading CRAM..."
    wget -q "${SAMPLE_URL}" -O "${CRAM}"
fi

# Check + download CRAI
if [ -f "${CRAI}" ]; then
    echo "CRAI already exists: ${CRAI} — skipping download"
else
    echo "Downloading CRAI..."
    wget -q "${SAMPLE_URL}.crai" -O "${CRAI}"
fi

echo "Sample done downloading!"
