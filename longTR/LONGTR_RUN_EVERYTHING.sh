#!/bin/bash

jobid_longtr_full_pipeline=$(sbatch --parable longtr_full_pipeline_copy.sbatch)
# delete intermediate chr vcf files
jobid_filter_longtr_by_dp_q=$(sbatch --parable=afterok:$jobid_longtr_full_pipeline filter_longtr_by_dp_q_copy.sbatch)
# delete intermediate files
jobid_create_bed_for_matrix=$(sbatch --parable=afterok:$jobid_filter_longtr_by_dp_q create_bedfile_for_matrix.sbatch)
sbatch 

check_vcf_files_genotyped.sbatch   logs                                       longtr_remove_files.sbatch
create_bedfile_for_matrix.sbatch   longtr_filter_vcf_find_num_repeats.sbatch  lontr_number_of_repeats_check.py
filter_longtr_by_dp_q_copy.sbatch  longtr_full_pipeline_copy.sbatch           number_of_repeats_check.sbatch
