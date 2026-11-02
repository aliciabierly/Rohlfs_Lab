#!/bin/bash


samtools view HG00096.chr10.withqual.bam | awk '
{
    hp=0
    for(i=12;i<=NF;i++)
        if($i ~ /^HP:i:[12]$/) hp=1

    if(hp) tagged++
    else untagged++
}
END {
    print "HP-tagged:", tagged
    print "Untagged:", untagged
}'

