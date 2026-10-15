#!/bin/bash
#SBATCH --job-name=index_file
#SBATCH --mem=20G
#SBATCH --time=5:00:00
#SBATCH --cpus-per-task=30
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --partition=compute
#SBATCH --array=1-1
#SBATCH --account=rohlfslab
#SBATCH --output=logs/index_%A_%a.out
#SBATCH --error=logs/index_%A_%a.err

module load bcftools
module load miniconda3
module load bedtools
module load parallel
# conda activate longtr_venv
SAMPLE_FILE="/projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt"

OUTDIR="/scratch/rohlfslab/abierly2/hmmix"
mkdir -p "${OUTDIR}/tmp"

SNP_INDEL_FILE="${OUTDIR}/tmp/snp_indel_file.bcf.gz"
FILTERED_SNP_INDEL_FILE="${OUTDIR}/tmp/chr${SLURM_ARRAY_TASK_ID}.bcf.gz"
FINAL_BCF="${OUTDIR}/chr${SLURM_ARRAY_TASK_ID}.bcf"

# download file
if [[ ! -f "$SNP_INDEL_FILE" ]]; then
    wget "https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/variants/1000_Genomes_Project/chm13v2.0/Phased_SHAPEIT5_v1.1/1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.biallelic.2504.bcf.gz" -O "$SNP_INDEL_FILE"
    wget "https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/variants/1000_Genomes_Project/chm13v2.0/Phased_SHAPEIT5_v1.1/1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.biallelic.2504.bcf.gz.csi" -O "${SNP_INDEL_FILE}.csi"
fi

### STEP 1: SAMPLE ID AND ANCESTRY INFORMATION
# make sample population file
# only include populations with superpopulation codes
# do not include ind with African descent from the population groups of ASW and ACB
# these ind have experiences admixture
SAMP_POP_FILE="${OUTDIR}/tmp/population.txt"
SAMPLE_IDS="${OUTDIR}/tmp/sample_ids.txt"
if [[ ! -f "$SAMP_POP_FILE" ]]; then
    awk '($5=="AFR" || $5=="AMR" || $5=="EAS" || $5=="EUR" || $5=="SAS") && $4!="ASW" && $4!="ACB" {printf("%s\t%s\n", $1, $5)}' "/projects/rohlfslab/abierly2/Rohlfs_Lab/data/igsr_samples.tsv" > $SAMP_POP_FILE
    awk '{print $1}' "$SAMP_POP_FILE" > "$SAMPLE_IDS"
fi

# make json file with sample information for hmmix
SAMPLE_JSON="${OUTDIR}/tmp/individuals.json"
if [[ ! -f "${SAMPLE_JSON}" ]]; then
conda activate ds_env
SAMPLE_JSON="$SAMPLE_JSON" SAMP_POP_FILE="$SAMP_POP_FILE" \
    python - <<'PY'

import json
import os

ingroup, outgroup = [], []
with open(os.environ["SAMP_POP_FILE"]) as f:
    for line in f:
        line = line.strip().split("\t")
        if line[1] == "AFR":
            outgroup.append(line[0])
        else:
            ingroup.append(line[0])

with open(os.environ["SAMPLE_JSON"], "w") as f:
    json.dump({"ingroup": ingroup, "outgroup": outgroup}, f, indent=2)
    f.write("\n")
PY
conda deactivate
fi

### STEP 2: FILTER SV FILE
# make per chr files and filter for sample IDs
# calculate some stats over all samples: AC,AF,AN,NS,DP
SNP1_INDEL_FILE="${OUTDIR}/tmp/chr${SLURM_ARRAY_TASK_ID}_1.bcf.gz"
SNP2_INDEL_FILE="${OUTDIR}/tmp/chr${SLURM_ARRAY_TASK_ID}_2.bcf.gz"
bcftools view -S "$SAMPLE_IDS" -r "chr${SLURM_ARRAY_TASK_ID}" "$SNP_INDEL_FILE" -Ob --force-samples | \
    bcftools +fill-tags --write-index -Ob -o $SNP1_INDEL_FILE -- -t AC,AF,AN,NS

# calculate AF per population group for hmmix
bcftools +fill-tags $SNP1_INDEL_FILE -Ob -o $SNP2_INDEL_FILE -- -S $SAMP_POP_FILE -t AF

gunzip -c $SNP2_INDEL_FILE > $FINAL_BCF
bcftools index $FINAL_BCF

# remove intermediate files
#rm "chr${SLURM_ARRAY_TASK_ID}.bcf.gz"

conda activate hmmix
touch "strictmask.bed" # this is empty

REF="/projects/rohlfslab/shared/reference_genomes/1KG_ONT_VIENNA_t2t_REFERENCE.fa"
OUTGROUP_TXT="${OUTDIR}/outgroup_chr${SLURM_ARRAY_TASK_ID}.txt"
MUTATION_BED="${OUTDIR}/mutationrate_chr${SLURM_ARRAY_TASK_ID}.bed"
# running hmmix
cd /scratch/rohlfslab/abierly2/hmmix
hmmix create_outgroup -ind=$SAMPLE_JSON -vcf=$FINAL_BCF -weights="strickmask.bed" -out=$OUTGROUP_TXT -refgenome=$REF
hmmix mutation_rate -outgroup=$OUTGROUP_TXT  -weights="strickmask.bed" -window_size=1000000 -out $MUTATION_BED
hmmix create_ingroup  -ind=$SAMPLE_JSON -vcf=$FINAL_BCF -weights="strickmask.bed" -out=obs -outgroup=$OUTGROUP_TXT

parallel MUTATION_BED="$MUTATION_BED" -j "$SLURM_CPUS_PER_TASK" '
    cd /scratch/rohlfslab/abierly2/hmmix
    hmmix train  -obs=obs.{}.txt -weights="strickmask.bed" -mutrates=$MUTATION_BED -out=trained.{}.phased.json -haploid
    hmmix decode -obs=obs.{}.txt -weights="strickmask.bed" -mutrates=$MUTATION_BED -param=trained.{}.phased.json -out={}.decoded -haploid
' ::: $(awk '$2 != "AFR" {print $1}' "$SAMP_POP_FILE")

conda deactivate
