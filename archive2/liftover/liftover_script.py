from pyliftover import LiftOver
import random
import numpy as np

# Try both directions
# lo_hg19_to_hg38 = LiftOver('hg19', 'hg38')
lo_hg38_to_hg19 = LiftOver('hg38', 'hg19')

# Read your BED file
with open('cleaned_introgressed_final.bed') as f:
    lines = [line.strip().split() for line in f]

# Pick 5 random tracts to test
# sample_lines = random.sample(lines, min(5, len(lines)))

# print(lines)
def liftover(lo, lines):
    for chrom, start, end in lines:
        start = int(start)
        end = int(end)
        print(f"{chrom}\t{lo.convert_coordinate(chrom, start)}\t{lo.convert_coordinate(chrom, end)}")
    return

# Test both directions
# print("hg19_to_hg38_ratio")
hg38_to_hg19ratio = liftover(lo_hg38_to_hg19, lines)
