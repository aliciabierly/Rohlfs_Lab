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
    '''

    period = int(v.INFO.get("PERIOD"))
    ref_length = len(v.REF)
    #format = v.FORMAT.split(":")
    #gb_position = format.index("GB")
    #sample_info = v.SAMPLE.split(":")
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

    return f"{repeat_lengths[0]}|{repeat_lengths[1]}"

def main():
    input_vcf = VCF(sys.argv[1])
    input_vcf.add_info_to_header({"ID": "R",
                            "Description": "repeat number per allele",
                            "Type": "Character", "Number": "1"})

    output_vcfname = sys.argv[2]
    output_vcf = Writer(output_vcfname, input_vcf)
    keep_all_rows = sys.argv[3]

    for v in input_vcf:
        r = calculate_repeat_length(v, keep_all_rows)
        v.INFO["R"] = r
        output_vcf.write_record(v)

    output_vcf.close(), input_vcf.close()
    return

main()
