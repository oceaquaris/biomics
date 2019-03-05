#!/bin/bash -l
#PBS -N fastq2tsv
#PBS -q standby
#PBS -l nodes=1:ppn=2,walltime=4:00:00

cd $PBS_O_WORKDIR

forward='036570_15_S134_R1_filtered.fastq'
reverse='036570_15_S134_R2_filtered.fastq'

awk '{
    if(NR == 1)
        {printf("%s", $1)}
    else if((NR-1) % 4 == 0)
        {printf("\n%s", $1)}
    else
        {printf("\t%s", $1)}
}' $forward > "${forward%.*}.tsv"

awk '{
    if(NR == 1)
        {printf("%s", $1)}
    else if((NR-1) % 4 == 0)
        {printf("\n%s", $1)}
    else
        {printf("\t%s", $1)}
}' $reverse > "${reverse%.*}.tsv"
