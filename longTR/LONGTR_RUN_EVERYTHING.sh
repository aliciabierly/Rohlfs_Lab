#!/bin/bash

jobid_longtr_full_pipeline=$(sbatch --parsable longtr_full_pipeline_copy.sbatch)
jobid_filter_longtr_by_dp_q=$(sbatch --parsable --depend=afterok:$jobid_longtr_full_pipeline filter_longtr_by_dp_q_array.sbatch)
jobid_create_bed_for_matrix=$(sbatch --parsable --depend=afterok:$jobid_filter_longtr_by_dp_q create_bedfile_for_matrix.sbatch)
jobid_make_matrix=$(sbatch --parsable --depend=afterok:$jobid_create_bed_for_matrix make_matrix.sbatch)
jobid_transform_matrix=$(sbatch --depend=afterok:$jobid_make_matrix transform_matrix.sbatch)
#jobid_remove_files=$(sbatch --parable=afterok:$jobid_transform_matrix ./remove_intermediate_files.sh)
