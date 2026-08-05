#!/bin/bash

awk -F'\t' '{ OFS="\t" }
{
  split($4, a, ";")
  for (i in a) {
    if (a[i] ~ /^MOTIFS=/) {
      sub(/^MOTIFS=/, "", a[i])
        print $1, $2, $3, a[i]
    }
  }
}' homo_mucin_catalog.bed > TR_homo_mucin_catalog_normalized.bed
