#!/bin/bash
#SBATCH --job-name=merge_TR_archaic_array
#SBATCH --partition=compute
#SBATCH --account=rohlfslab

#SBATCH --array=1-663%50
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --time=05:00:00

#SBATCH --output=merge_TR_archaic_%A_%a.out
#SBATCH --error=merge_TR_archaic_%A_%a.err

set -euo pipefail

TRACTS_DIR="/gpfs/scratch/rohlfslab/abierly"
if [ ! -f "${TRACTS_DIR}/t2t_coordinates_mapped.bed" ]; then
    echo "Archaic tract document is not present."
#    sbatch ~/liftover/liftover_hg38_t2t_bysegment/clean_hg38_1000g_segments.sbatch
fi

### SAMPLE SELECTION for parallelization
SAMPLE_LIST="/projects/rohlfslab/shared/hannah_alicia_shared_sampleIDs.txt"
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLE_LIST")

#echo "\nProcessing sample: $SAMPLE"
srun --ntasks=1 copy_merge_1KG_tr_archaic_data.sh "$SAMPLE"
