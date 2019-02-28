#!/bin/bash -l
#PBS -N samvalidate
#PBS -q standby
#PBS -l nodes=1:ppn=1,walltime=4:00:00,mem=128gb,naccesspolicy=singlejob

module load bioinfo
module load picard-tools

cd $PBS_O_WORKDIR

for file in *.sam
do
    PicardCommandLine ValidateSamFile \
        INPUT=${file} \
        MODE=VERBOSE \
        OUTPUT=${file%.*}.verbose.validation \
        MAX_OUTPUT=1000000
done
