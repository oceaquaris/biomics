#!/bin/bash -l
#PBS -N nr_blast
#PBS -q standby
#PBS -l nodes=1:ppn=20,walltime=04:00:00,naccesspolicy=singlejob

# Change to the directory
cd $PBS_O_WORKDIR

MAX_EVALUE="1e-3"
QUERY_FILE="TraesCS5A02G353500.faa"
BLAST_HITS="${QUERY_FILE%.*}.blast.tsv"
ACC_HITS="${BLAST_HITS%.*}.acc.tsv"
ACC_HITS_FAA="${ACC_HITS}.faa"

# load modules
module load bioinfo
module load blast
#module load mafft

# query the refseq_protein database
blastp \
    -query $QUERY_FILE \
    -db nr_protein \
    -evalue $MAX_EVALUE \
    -outfmt 6 \
    -out $BLAST_HITS \
    -num_threads $PBS_NUM_PPN

# get the second column of the hits, sort, get only uniqes
cut -f 2 $BLAST_HITS | sort --unique > $ACC_HITS

# get full-length sequencese from the refseq_protein database.
blastdbcmd \
    -entry_batch $ACC_HITS \
    -db nr_protein \
    -target_only \
    -out $ACC_HITS_FAA

cat $QUERY_FILE >> $ACC_HITS_FAA

#align sequences using mafft
#mafft \
#    --thread 10 \
#    --threadtb 5 \
#    --threadit 0 \
#    --reorder \
#    --maxiterate 1000 \
##    --localpair $ACC_HITS_FAA \
#    > $ACC_HITS_ALN
