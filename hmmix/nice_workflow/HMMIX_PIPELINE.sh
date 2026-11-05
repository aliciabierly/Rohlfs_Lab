#!/bin/bash
OUTDIR="/scratch/rohlfslab/abierly/hmmix"
jobid_snps_file=$(sbatch --parsable snps_file.sh $OUTDIR)
jobid_create_run_outgroup=$(sbatch --parsable --depend=afterok:$jobid_snps_file create_run_outgroup.sh $OUTDIR)
jobid_train_decode_hmmix=$(sbatch --parsable --depend=afterok:$jobid_create_bed_for_matrix train_decode_hmmix.sh $OUTDIR)
jobid_merge_final_table=$(sbatch --depend=afterok:$jobid_train_decode_hmmix merge_final_table.sh $OUTDIR)
