#!/bin/bash
jobid_merge_1KG_tr_archaic_data=$(sbatch --parsable merge_1KG_tr_archaic_data.sbatch)
jobid_fix_data_merge_data=$(sbatch --parsable --depend=afterok:$jobid_merge_1KG_tr_archaic_data fix_data_merge_data.sbatch)
jobid_make_matrix=$(sbatch --parsable --depend=afterok:$jobid_fix_data_merge_data make_matrix.sbatch)
jobid_transform_matrix=$(sbatch --depend=afterok:$jobid_make_matrix transform_matrix.sbatch)
