#!/bin/bash

python3 > PY

import pandas as pd
import numpy as np

matrix_longtr_file="/scratch/rohlfslab/abierly2/LongTR/matrix_final/all.gt.t.txt"
matrix_longtr_gf_file="/scratch/rohlfslab/abierly2/LongTR_gf/matrix_final/all.gt.t.txt"
ouput_file="/scratch/rohlfslab/abierly2/LongTR_gf/matrix_final/find_diff_length_TRs_entire_matrix.txt"
catalog_file="/scratch/rohlfslab/abierly2/LongTR_gf/TR_catalog_normalized_sorted.bed"

def compare_genotypes(val1:str, val2:str, motif):
    ''' this function takes in two genotypes in the form of float|float 
    it compares the smallest and largest values from each
    '''
    motif_len = len(motif)
    if val1=="." and val1==".":
        return "."
    if val1==".":
        return "NA_default"
    if val2==".":
        return "NA_gf"
    al1_val1, al2_val1 = val1.split("|")
    al1_val2, al2_val2 = val2.split("|")
    al1_val1, al2_val1 = float(al1_val1), float(al2_val1)
    al2_val1, al2_val2 = float(al1_val2), float(al2_val2)
    al1_val1, al2_val1 = np.round(al1_val1*motif_len), np.round(al2_val1*motif_len)
    al1_val2, al2_val2 = np.round(al1_val2*motif_len), np.round(al2_val2*motif_len)
    mean_absolute_allele_diff = (np.abs(al1_val1 - al1_val2) + np.abs(al2_val1 - al2_val2)) / 2
    genotype_span = (al1_val1 + al1_val2) - (al2_val1 + al2_val2)
    max_allele_diff = np.abs(max(al1_val1, al1_val2) - max(al2_val1, al2_val2))
    return mean_absolute_allele_diff, genotype_span, max_allele_diff


with open(matrix_longtr_file, "r") as matrix_longtr, open(matrix_longtr_gf_file, "r") as matrix_longtr_gf, open(catalog_file, "r") as matrix_catalog, open(ouput_file, "w") as matrix_output:
    matrix_output.write("mean_absolute_allele_diff\tgenotype_span\tmax_allele_diff")
    for line_longtr, line_longtr_gf, catalog_line in zip(matrix_longtr, matrix_longtr_gf, matrix_catalog):
        chr, start, end, motif = catalog_line.strip().split("\t")
        line1 = line_longtr.strip().split("\t") # remove white space around
        line2 = line_longtr_gf.strip().split("\t")
        for i in range(len(line1)):
            val1, val2 = line1[i], line2[i]
            mean_absolute_allele_diff, genotype_span, max_allele_diff = compare_genotypes(val1, val2)
            
