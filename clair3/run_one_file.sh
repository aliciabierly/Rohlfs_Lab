#!/bin/bash
#SBATCH --job-name=clair3
#SBATCH --mem=10G
#SBATCH --time=5:00:00                 # increased time for reliability
#SBATCH --cpus-per-task=10
#SBATCH --ntasks=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/clair3_%A_%a.out
#SBATCH --error=logs/clair3_%A_%a.err   # Keep error files !

module load miniconda3
conda activate clair3

SAMPLE="HG00096"
THREADS=10
MODEL_NAME="r941_prom_sup_g5014"
CHR="chr1"

REF_DIR="/projects/rohlfslab/shared/reference_genomes"
SCRATCH="/scratch/rohlfslab/abierly2"
REF="${REF_DIR}/1KG_ONT_VIENNA_t2t_REFERENCE.fa"
OUTDIR_CRAM="${SCRATCH}/crams"
CRAM="${OUTDIR_CRAM}/${SAMPLE}.t2t.cram"
CRAI="${CRAM}.crai"
QUAL_BAM="${SAMPLE}_withqual.bam"
OUTPUT_DIR="${SCRATCH}/clair3"

mkdir $OUTPUT_DIR
echo "Make BAM: $(date)"

samtools view -h --reference $REF $CRAM  $CHR | \
    perl -F'\t' -lane '
        if ($F[0] =~ /^@/) {
            print;
            next;
        }
	if ($F[9] ne "*" && $F[10] eq "*") {
            $F[10] = "0" x length($F[9]);
        }
	print join("\t", @F);
    ' | \
samtools view -b -o $QUAL_BAM - || exit 1
samtools index $QUAL_BAM || exit 1

echo "Run Clair3 on ${CHR}: $(date)"

run_clair3.sh \
  --bam_fn=${QUAL_BAM} \
  --ref_fn=${REF} \
  --threads=${THREADS} \
  --platform=ont \
  --model_path="${OUTPUT_DIR}/r941_prom_sup_g5014" \
  --output=${OUTPUT_DIR} \
  --use_whatshap_for_final_output_phasing \
  --use_whatshap_for_final_output_haplotagging

echo "Done!!: $(date)"

conda deactivate
