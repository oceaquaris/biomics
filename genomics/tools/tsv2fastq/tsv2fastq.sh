#!/bin/bash

if [ "$#" -eq "0" ]
then
    echo "Usage: $0 INTSV"
    exit 1
elif [ -e "$1" ]
then
    cat $1 | tr '\t' '\n' > "${1%.*}.fastq"
    #awk '{print $1; print $2; print $3; print $4}' $1
fi
