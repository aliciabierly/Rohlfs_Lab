#!/bin/bash

jobid_calculate_n_deletions=$(sbatch --parsable calculate_n_deletions.sbatch)
sbatch --depend=afterok:${jobid_calculate_n_deletions} combine_n_deletions.sbatch
