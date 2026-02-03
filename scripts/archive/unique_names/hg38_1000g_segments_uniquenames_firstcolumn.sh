#!/bin/bash
# this creates a file of the indiduals names; only works if the name is first in row 

for file in "$@"; do
	touch "${file%.txt}_names.txt"
	touch "${file%.txt}_names_unique.txt"
	cut -f1 "$file" > "${file%.txt}_names.txt"
	sort "${file%.txt}_names.txt" | uniq > "${file%.txt}_names_unique.txt"
done
