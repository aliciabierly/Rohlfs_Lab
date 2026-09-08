#!/bin/bash


# subset data for only values where there is at least 1 individual arachic for both tracts
awk '$NF!=0 {priont $0}' > 
