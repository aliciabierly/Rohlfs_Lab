# This file takes in a csv file that contains the TR genotype information.
# Each row is one loci / TR. Each column is one ind.
# The file creates a new file called heterzygosity.csv which contains
# heterozygosity, one_allele_genotyped (count of values of ".|int" form
# and total

import pandas as pd
import numpy as np

# create table
chunks = pd.read_csv("TR_genotypes.csv", chunksize=10_000)  
collected_rows = []  
total_rows = 0  
 
for chunk in chunks:  
    # Add chunk to collected rows  
    collected_rows.append(chunk)  
    total_rows += len(chunk)  
df = pd.concat(collected_rows)

# create function to apply to the table
def find_heterozygousity(arr: np.array):
    ''' this function takes in a numpy array and 
    returns the heterozygousity ofa particular TR loci
    
    Values contained in the array: 
    "." = no genotype,
    ".|int" = one allele genotype, 
    "int|int" = both alleles genotyped 
    '''
    
    ctr = 0
    total = 0
    ctr_one_allele = 0
    for ind in arr:
        if ind != ".": # check if no genotype for either allele
            a1, a2 = ind.split("|")
            if a1 != "." and a2 != ".": # check if one allele was not genotyped
                total += 1
                if a1 != a2:
                    ctr += 1
            else:
                ctr_one_allele += 1

    if total == 0:
        return np.nan, ctr_one_allele, total
    return ctr/total, ctr_one_allele, total

hetero_df = df.apply(find_heterozygousity, axis=1).reset_index()
hetero_df[["heterozygosity", "one_allele_genotyped", "total"]] = hetero_df[0].apply(pd.Series)
hetero_df = hetero_df[["heterozygosity", "one_allele_genotyped", "total"]]
hetero_df.to_csv("heterzygosity.csv")
