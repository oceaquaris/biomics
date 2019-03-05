#!/bin/bash

if [ "$#" -eq "0" ]
then
    echo "Usage: $0 INFASTQ"
    exit 1
elif [ -e "$1" ]
then
    awk \
    '{
        if(NR == 1)
            {printf("%s", $1)}
        else if((NR-1) % 4 == 0)
            {printf("\n%s", $1)}
        else
            {printf("\t%s", $1)}
    }' $1
fi

702706220
