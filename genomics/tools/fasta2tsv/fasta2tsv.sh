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
        }END{printf("\n")}' $1 | sed 's/ /\t/g'
fi
