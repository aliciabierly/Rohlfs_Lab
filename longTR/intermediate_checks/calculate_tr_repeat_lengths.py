# need to tell it to be in ds_env
# python file will run on just the ind files, will multiply the period * 2.5.
# calculate the len(REF)
# seperate the GB values
# add each GB value to the len(REF)
# compare to period * 2.5 threshold and if higher, count if lower put NA.

# import libraries
import sys

# command line args
def main():
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    with open(input_file, "r") as input, \
        open(output_file, "w") as output:
        # cols = input.readline().strip(",")
        for line in input:
            chrom, start, end, period, ref, gb = line.split(",")

            # fix variables
            # gb = bp difference from reference length per allele
            # use length of reference + gb per allele to find length of TR
            period = int(period)
            gb = gb.split("|")
            al1_diff, al2_diff = int(gb[0]), int(gb[1])
            ref_length = len(ref)

            # calculate number of repeats, remove TRs < 2.5 REPEATS long
            al1 = (ref_length + al1_diff)/period
            al2 = (ref_length + al2_diff)/period
            al1_mask, al2_mask = al1 >= 2.5, al2 >= 2.5
            if al1_mask or al2_mask:
                output.write(f"chrom,start,end,period,")
