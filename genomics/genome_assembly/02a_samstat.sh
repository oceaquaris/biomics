#!/bin/bash -l
#PBS -N samsplit
#PBS -q standby
#PBS -l nodes=1:ppn=1,walltime=4:00:00

cd $RCAC_SCRATCH/assembly/02_bwa_mem

# load modules
module load bioinfo
module load samtools

# start by computing statistics on the paired read file
for sam in *.sam
do
    samtools flagstat "${sam}" > "${sam%.*}.stat"
done
