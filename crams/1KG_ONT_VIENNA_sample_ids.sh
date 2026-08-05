# this file finds the unique sample ids shared between 1KG_ONT_VIENNA study and hmmix dataset
curl -s ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1KG_ONT_VIENNA/t2t/ \
  | awk -F'.t2t.cram' '/\.t2t\.cram/ {print $1}' \
  | awk -F'>' '{print $NF}' \
  | awk '{print $9}' | uniq > sample_ids.txt

curl -s https://zenodo.org/records/14136628/files/hg38_1000g_segments.txt \
  | cut -f1 \
  | uniq > unique_sample_ids.txt

sort sample_ids.txt -o sample_ids.sorted.txt
sort unique_sample_ids.txt -o unique_sample_ids.sorted.txt

comm -12 sample_ids.sorted.txt unique_sample_ids.sorted.txt > shared_ids.txt
