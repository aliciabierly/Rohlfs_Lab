#!/bin/bash

for f in *.chr21.haplotagged.bam; do \
    A=$(samtools view "$f" | wc -l); \
    B=$(samtools view "$f" | grep "HP" | wc -l); echo "$(basename "$f"),${A},${B}"; \

done > calculate_percent_haplotagged.csv
