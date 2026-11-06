#!/bin/bash
#SBATCH --job-name=index_file
#SBATCH --mem=5G
#SBATCH --time=2:00:00
#SBATCH --cpus-per-task=8
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/index_%A_%a.out
#SBATCH --error=logs/index_%A_%a.err

module load bcftools
module load miniconda3
module load bedtools
module load parallel
# conda activate longtr_venv
SAMPLE_FILE="/projects/rohlfslab/abierly2/Rohlfs_Lab/data/filtered_samples_min_dp_14.txt"

OUTDIR=$1
OUTDIR_FINAL_SNP="/scratch/rohlfslab/abierly/hmmix_files/snp_files"
mkdir -p "${OUTDIR}/tmp"
mkdir -p "$OUTDIR_FINAL_SNP"

SNP_INDEL_FILE="${OUTDIR}/tmp/snp_indel_file.bcf.gz"

if [[ -f "${OUTDIR_FINAL_SNP}/chr1.bcf" ]]; then
   echo "SNP files already exist. Exiting"
   exit 0
fi

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
echo "Fix SV file: $(date)"
SAMP_POP_FILE="${OUTDIR}/tmp/population.txt"
SAMPLE_IDS="${OUTDIR}/tmp/sample_ids.txt"
if [[ ! -f "$SAMP_POP_FILE" ]]; then
    awk '($5=="AFR" || $5=="AMR" || $5=="EAS" || $5=="EUR" || $5=="SAS") && $4!="ASW" && $4!="ACB" {printf("%s\t%s\n", $1, $5)}' "/projects/rohlfslab/abierly2/Rohlfs_Lab/data/igsr_samples.tsv" > $SAMP_POP_FILE
    bcftools query -l "$SNP_INDEL_FILE" > "${OUTDIR}/tmp/bcf_sample_ids.txt"
    awk 'NR==FNR {available[$1]=1; next} $1 in available' "${OUTDIR}/tmp/bcf_sample_ids.txt" "$SAMP_POP_FILE" > "${OUTDIR}/tmp/population.filtered.txt"
    mv "${OUTDIR}/tmp/population.filtered.txt" "$SAMP_POP_FILE"
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
echo "Starting to recalculate variables in SV file: $(date)"

export OUTDIR OUTDIR_FINAL_SNP SAMPLE_IDS SNP_INDEL_FILE SAMP_POP_FILE
parallel -j "${SLURM_CPUS_PER_TASK}" '
    FILTERED_SNP_INDEL_FILE="${OUTDIR}/tmp/chr{}.bcf.gz"
    FINAL_BCF="${OUTDIR}/chr{}.bcf"

    SNP1_INDEL_FILE="${OUTDIR}/tmp/chr{}_1.bcf.gz"
    SNP2_INDEL_FILE="${OUTDIR}/tmp/chr{}_2.bcf.gz"
    bcftools view -S "$SAMPLE_IDS" -r "chr{}" "$SNP_INDEL_FILE" -Ob --force-samples | \
        bcftools +fill-tags --write-index -Ob -o $SNP1_INDEL_FILE -- -t AC,AF,AN,NS

    # calculate AF per population group for hmmix
    bcftools +fill-tags $SNP1_INDEL_FILE -Ob -o $SNP2_INDEL_FILE -- -S $SAMP_POP_FILE -t AF

    gunzip -c $SNP2_INDEL_FILE > $FINAL_BCF
    bcftools index $FINAL_BCF
    mv $FINAL_BCF "${FINAL_BCF}.csi" $OUTDIR_FINAL_SNP
' ::: {1..22}

SAMPLE_INFO_DIR="/scratch/rohlfslab/abierly2/hmmix_files/sample_info"
mkdir -p $SAMPLE_INFO_DIR

mv $SAMP_POP_FILE $SAMPLE_IDS $SAMPLE_JSON $SAMP_POP_FILE $SAMPLE_INFO_DIR
