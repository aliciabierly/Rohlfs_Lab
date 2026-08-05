#!/usr/bin/env python3
# NOTE: this only gets rid of rows were BOTH alleles are
# have repeats < 2.5 . Will have to filter for each allele after.
import argparse
import pysam

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", required=True)
parser.add_argument("-o", "--output", required=True)
args = parser.parse_args()

vcf = pysam.VariantFile(args.input)
out = pysam.VariantFile(args.output, "wz", header=vcf.header)

for rec in vcf:
    period = rec.info["PERIOD"]
    ref_len = len(rec.ref)

    new_gb = list(sample["GB"])

    for i, reps in enumerate(allele_repeats):
        if reps < 2.5:
            gt[i] = None
            new_gb[i] = None   # or "." depending on the field type

    sample["GT"] = tuple(gt)
    sample["GB"] = tuple(new_gb)
    out.write(rec)

out.close()

pysam.tabix_index(args.output, preset="vcf", force=True)
