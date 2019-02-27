#!/bin/bash -l
#PBS -N mystery_blast
#PBS -l nodes=1:ppn=20
#PBS -l walltime=04:00:00
#PBS -q scholar
#PBS -l naccesspolicy=singlejob
#PBS -l epilogue=/depot/jwisecav/darwin/queue_stuff/epilogue.sh

# Change to the directory from which you submitted this job
cd $PBS_O_WORKDIR

MAX_EVALUE="1e-3"
BLAST_HITS="mystery_sequence_hits_raw_blast.tsv"
ACCESSION_HITS="mystery_sequence_hits_accessions_nonredundant.tsv"
ACCESSION_HITS_FAA="mystery_sequence_hits_accessions_nonredundant.faa"
ACCESSION_HITS_ALN="mystery_sequence_hits_accessions_nonredundant.aln"
ACCESSION_HITS_TREE="mystery_sequence_hits_accessions_nonredundant.tree"

# load modules
module load bioinfo
module load blast
module load mafft
module load FastTree

# query the refseq_protein database
blastp \
    -query mystery_sequence.faa \
    -db refseq_protein \
    -evalue $MAX_EVALUE \
    -max_target_seqs 50 \
    -outfmt 6 \
    -out $BLAST_HITS \
    -num_threads $PBS_NUM_PPN

# get the second column of the hits, sort, get only uniqes
cut -f 2 $BLAST_HITS | sort --unique > $ACCESSION_HITS

# get full-length sequencese from the refseq_protein database.
blastdbcmd \
    -entry_batch $ACCESSION_HITS \
    -db refseq_protein \
    -target_only \
    -out $ACCESSION_HITS_FAA

cat mystery_sequence.faa >> $ACCESSION_HITS_FAA

#align sequences using mafft
mafft \
    --thread 10 \
    --threadtb 5 \
    --threadit 0 \
    --reorder \
    --maxiterate 1000 \
    --retree 1 \
    --localpair $ACCESSION_HITS_FAA \
    > $ACCESSION_HITS_ALN

FastTree \
    $ACCESSION_HITS_ALN \
    > $ACCESSION_HITS_TREE
