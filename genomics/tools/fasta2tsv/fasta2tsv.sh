#!/bin/bash

if [ "$#" -eq "0" ]
then
    echo "Usage: $0 INFASTA"
    exit 1
elif [ -e "$1" ]
then
    awk '{
            if(substr($1,1,1) == ">")
                if(NR > 1)
                    printf("\n%s\t", substr($0,2,length($0)-1))
                else
                    printf("%s\t", substr($0,2,length($0)-1))
            else
                printf("%s", $0)
        }END{printf("\n")}' $1 | tee /tmp/fasta.tsv | cut -f 2 > /tmp/fasta.seqs
    cut -d $'\t' -f 1 /tmp/fasta.tsv | sed 's/ pep/\tpep/g; s/ chromosome:/\tchromosome:/g; s/ gene:/\tgene:/g; s/ transcript:/\ttranscript:/g; s/ gene_biotype:/\tgene_biotype:/g; s/ transcript_biotype:/\ttranscript_biotype:/g; s/ description:/\tdescription:/g' > /tmp/info.tsv
    paste <(cut -f 1,2,3,4,5,6,7 /tmp/info.tsv) <(cut -f 8 /tmp/info.tsv) /tmp/fasta.seqs
fi
