#!/bin/bash

# Group commands based on their array index.

# MODIFY ME: Array of blast tools to use:
#   blastn
#       Nucleotide-Nucleotide blast
#   blastp
#       Protein-Protein blast
#   blastx
#       Nucleotide-Protein blast
blast=(
[1]=blastx
)

# MODIFY ME: Array of databases to use during remote blast.
#   BLAST database name
#    * Incompatible with:  subject, subject_loc
#   BLAST database names:
#     
database=(
[1]="nr"
)

# MODIFY ME: Array of query files containing sequences to blast.
#   Input file name
#   Default = `-'
query=(
[1]="found_yield_genes_(CDS).fa"
)

# MODIFY ME: Array of integers indicating how data should be received:
#   alignment view options:
#      0 = Pairwise,
#      1 = Query-anchored showing identities,
#      2 = Query-anchored no identities,
#      3 = Flat query-anchored showing identities,
#      4 = Flat query-anchored no identities,
#      5 = BLAST XML,
#      6 = Tabular,
#      7 = Tabular with comment lines,
#      8 = Seqalign (Text ASN.1),
#      9 = Seqalign (Binary ASN.1),
#     10 = Comma-separated values,
#     11 = BLAST archive (ASN.1),
#     12 = Seqalign (JSON),
#     13 = Multiple-file BLAST JSON,
#     14 = Multiple-file BLAST XML2,
#     15 = Single-file BLAST JSON,
#     16 = Single-file BLAST XML2,
#     18 = Organism Report
outfmt=(
[1]=5
)

# MODIFY ME: Array of integers indicating maximum aligned sequences to receive:
#   Maximum number of aligned sequences to keep 
#   Not applicable for outfmt <= 4
#   Default = `500'
#    * Incompatible with:  num_descriptions, num_alignments
max_target_seqs=(
[1]=10
)

# MODIFY ME: Array of entrez queries to use for the search:
#   Restrict search with the given Entrez query
#    * Requires:  remote
entrez_query=(
[1]="Arabidopsis thaliana[organism]"
)

# MODIFY ME: Array of names of output files:
#   Output file name
#   Default = `-'
output=(
[1]="root_genes.xml"
)


for ((i=1;i<${#blast[*]};i++)); do
    blastexe=""

    # Build our command from scratch.
    [[ ! -z ${blast[i]} ]] && blastexe="${blastexe}${blast[i]} -remote"
    [[ ! -z ${database[i]} ]] && blastexe="${blastexe} -db ${database[i]}"
    [[ ! -z ${query[i]} ]] && blastexe="${blastexe} -query ${query[i]}"
    [ "${outfmt[i]}" -ne "0" ] && blastexe="${blastexe} -outfmt ${outfmt[i]}"
    [ "${max_target_seqs[i]}" -ne "0" ] && blastexe="${blastexe} -max_target_seqs ${max_target_seqs[i]}"
    [[ ! -z ${entrez_query[i]} ]] && blastexe="${blastexe} -entrez_query ${entrez_query[i]}"
    [[ ! -z ${output[i]} ]] && blastexe="${blastexe} -out ${output[i]}"

    # Print what we are about to execute
    printf "Executing: $blastexe"
    # Execute our built command
    $blastexe
done
