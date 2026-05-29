### VCF Files
print header: bcftools view --h HG00982.filtered.vcf.gz
pull specific col from TR loci for all files: for f in *.filtered.vcf.gz; do echo "$f"; bcftools query -r chr5:719378-719404 -f '[%PDP\n]' "$f"; done

### Reference File
pull out regions: samtools faidx GRCh38_no_alt_analysis_set_GCA_000001405.15.fasta chr1:777836-777950 chr2:1234567-1234789
