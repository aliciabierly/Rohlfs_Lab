#!/bin/bash

jobid_check_vcf_files_genotyped=$(sbatch --parsable check_vcf_files_genotyped.sbatch)
sbatch --depend=afterok:${jobid_check_vcf_files_genotyped} combine_vcf_files.sbatch
