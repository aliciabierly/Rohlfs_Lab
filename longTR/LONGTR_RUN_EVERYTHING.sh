#!/bin/bash

jobid_longtr_full_pipeline=$(sbatch --parable longtr_full_pipeline_copy.sbatch)
# delete intermediate chr vcf files
jobid_filter_longtr_by_dp_q=$(sbatch --parable=afterok:$jobid_longtr_full_pipeline filter_longtr_by_dp_q_copy.sbatch)
# delete intermediate files
jobid_create_bed_for_matrix=$(sbatch --parable=afterok:$jobid_filter_longtr_by_dp_q create_bedfile_for_matrix.sbatch)

jobid_make_matrix=$(sbatch --parable=afterok:$jobid_create_bed_for_matrix make_matrix.sbatch)

jobid_transform_matrix=$(sbatch --parable=afterok:$jobid_make_matrix transform_matrix.sbatch)
