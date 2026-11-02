#!/bin/bash

# vamos_pipeline.sbatch
jobid_sort_array=$(sbatch --parsable sort_array.sbatch)
jobid_create_bed=$(sbatch --parsable --depend=afterok:$jobid_sort_array create_bed.sbatch)
#jobid_make_matrix=$(sbatch --parsable --depend=afterok:$jobid_create_bed_for_matrix make_matrix.sbatch)
#jobid_transform_matrix=$(sbatch --depend=afterok:$jobid_make_matrix transform_matrix.sbatch)
#jobid_remove_files=$(sbatch --parable=afterok:$jobid_transform_matrix ./remove_intermediate_files.sh)

create_bed.sbatch  logs  LONGTR_RUN_NOT_LONGTR.sh  make_matrix.sh  make_matrix_vamos.sbatch  sort_array.sbatch  transform_matrix.sh  vamos_pipeline.sbatch  vamos_repo

