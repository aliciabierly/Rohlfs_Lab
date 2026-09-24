#!/bin/bash

CATALOG="/projects/rohlfslab/shared/TR_catalogs/TR_catalog_normalized.bed"
OUTDIR="/scratch/rohlfslab/abierly2/LongTR_fgneg1_haplotagged_monomers"

mkdir -p "$OUTDIR"

# run through catalog for numbers 1-22.
#for i in {1..22}
#do
#  awk -v chr="chr${i}" '$1 == chr && length($4)==1' "$CATALOG" > "${OUTDIR}/TR_catalog_chr${i}.bed"
#done

cat "${OUTDIR}"/TR_catalog_chr*.bed > "${OUTDIR}"/TR_catalog.bed
