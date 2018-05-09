#!/bin/bash

database="nr"
sequences="sequences.fasta"
outformat=13
max_target_seqs=10
output="organism"
entrez_query="Arabidopsis thaliana[organism]"


blastx \
  -remote \
  -db "${database}" \
  -query "${sequences}" \
  -outfmt "${outformat}" \
  -max_target_seqs "${max_target_seqs}" \
  -entrez_query "${entrez_query}" \
  -out "${output}"
