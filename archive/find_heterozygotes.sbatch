#!/bin/bash
#SBATCH --job-name=sv
#SBATCH --mem=32G
#SBATCH --time=23:0:00                 # increased time for reliability
#SBATCH --ntasks=8
#SBATCH --partition=compute
#SBATCH --account=rohlfslab
#SBATCH --output=logs/%A.out
#SBATCH --error=logs/%A.err   # Keep error files !

module load parallel
module load bcftools

SV_FILE="filtered.1KGP.CHM13v2.0.whole_genome.recalibrated.snp_indel.pass.phased.native_maps.2504.bcf.gz"
OUT_DIR="/scratch/rohlfslab/abierly2/sv_file"
OUT_FILE="${OUT_DIR}/snp_indel_pass.txt"

printf "chr\tpos\tn_het\n" > "$OUT_FILE"

mkdir -p "${OUT_DIR}/tmp"

parallel -j 8 '
    bcftools query \
        -r chr{} \
        -f "%CHROM\t%POS[\t%GT]\n" \
        '"$SV_FILE"' |
    awk '"'"'{
        n=0
        for(i=3;i<=NF;i++) {
            split($i,a,"|")
            if(a[1] != a[2]) n++
        }
        print $1, $2, n
    }'"'"' OFS="\t" > "${OUT_DIR}/tmp/chr{}.txt"
' ::: {1..22} X

cat "${OUT_DIR}/tmp/chr{1..22}.txt" >> "$OUT_FILE"

# summary table
# span of 
