#!/bin/bash
CHR=$1
SAMPLE=$2

SCRATCH="/scratch/rohlfslab/abierly2"
OUTDIR_CRAM="${SCRATCH}/crams"
CRAM="${OUTDIR_CRAM}/${SAMPLE}.t2t.cram"

REF_DIR="/projects/rohlfslab/shared/reference_genomes"
REF="${REF_DIR}/1KG_ONT_VIENNA_t2t_REFERENCE.fa"

SCRATCH="/scratch/rohlfslab/abierly2"
CATALOG_DIR="${SCRATCH}/LongTR_fgneg1_haplotagged"
CATALOG="${SCRATCH}/LongTR_fgneg1_haplotagged/TR_catalog_normalized_no_monomers.bed"

VARIANT_FILE="/projects/rohlfslab/abierly2/Rohlfs_Lab/whatshap/filtered.1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz"

# files to make
OUTDIR_MAIN="${SCRATCH}/LongTR_fgneg1_haplotagged_allsamps" ### MUST CHANGE
OUTDIR="${OUTDIR_MAIN}/longTR_pipeline_${SAMPLE}"
VCF_OUT="${OUTDIR}/${SAMPLE}.${CHR}.vcf.gz"
PHASED_VCF="${OUTDIR}/${SAMPLE}.${CHR}.phased.vcf.gz"
QUAL_BAM="${OUTDIR}/${SAMPLE}.${CHR}.withqual.bam"
HAP_BAM="${OUTDIR}/${SAMPLE}.${CHR}.haplotagged.bam"
BAMSDIR="${OUTDIR_MAIN}/bams"
mkdir -p "$OUTDIR"
mkdir -p "$BAMSDIR"

# Extract phased SNP VCF for this chromosome
bcftools view \
    -r "${CHR}" \
    -s "${SAMPLE}" \
    "${VARIANT_FILE}" \
    -Oz \
    -o "${PHASED_VCF}" || exit 1
bcftools index "${PHASED_VCF}" || exit 1

# extract bam file for the chromosome, add fake bq scores
samtools view -h --reference "${REF}" "${CRAM}" "${CHR}" | \
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
samtools view -b -o "${QUAL_BAM}" - || exit 1
samtools index "${QUAL_BAM}" || exit 1

# phase the bams
whatshap haplotag \
    --reference "${REF}" \
    "${PHASED_VCF}" \
    "${QUAL_BAM}" \
    -o "${HAP_BAM}" || exit 1
samtools index "${HAP_BAM}" || exit 1

rm -f \
    "${QUAL_BAM}" \
    "${QUAL_BAM}.bai" \
    "${PHASED_VCF}" \
    "${PHASED_VCF}.tbi"

mv "${HAP_BAM}" "${HAP_BAM}.bai" "${BAMSDIR}"

# rm -r "${OUTDIR}"
