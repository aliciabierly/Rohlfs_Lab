#!/usr/bin/env python3

# import libraries
import sys
from cyvcf2 import VCF, Writer

def calculate_repeat_length(v, keep_all_rows):
    '''
    v: one line of vcf file
    keep_all_rows: string
    This function takes a row of a vcf file (one TR variant)
    and outputs the repeat length for a TR loci per allele
    and whether the individual is homozygous for the TR.
    '''
    # get variables from line
    period = int(v.INFO.get("PERIOD"))
    ref_length = len(v.REF)
    gb = v.format("GB")[0].split("|")

    # calculations
    # gb = bp difference from reference length per allele
    # use length of reference + gb per allele to find length of TR
    repeat_lengths = []
    for diff in map(int, gb): # run through 2 GB values
        length = (ref_length + diff)/period

        if keep_all_rows == "False" and length < 2.5:
            repeat_lengths.append("NA")
        else:
            repeat_lengths.append(str(length))
    het = repeat_lengths[0] != repeat_lengths[1]
    return f"{repeat_lengths[0]}|{repeat_lengths[1]}", het

def main():
    input_vcf = VCF(sys.argv[1])
    input_vcf.add_info_to_header({"ID": "R",
                            "Description": "repeat number per allele",
                            "Type": "Character", "Number": "1"})
    input_vcf.add_info_to_header({"ID": "HET",
                            "Description": "het=1, homo=0",
                            "Type": "Integer", "Number": "1"})

    output_vcfname = sys.argv[2]
    output_vcf = Writer(output_vcfname, input_vcf)
    keep_all_rows = sys.argv[3]

    for v in input_vcf:
        r, het = calculate_repeat_length(v, keep_all_rows)
        v.INFO["R"] = r
        v.INFO["HET"] = het
        output_vcf.write_record(v)

    output_vcf.close(), input_vcf.close()
    return

main()
