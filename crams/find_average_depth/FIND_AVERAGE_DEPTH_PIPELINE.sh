#!/bin/bash
# queue to sbatch jobs to create final file

jobid_average_depth_per_chromosome=$(sbatch --parsable find_average_depth_per_chromosome.sbatch)
sbatch --depend=afterok:$jobid_average_depth_per_chromosome find_average_depth_per_sample.sbatch
