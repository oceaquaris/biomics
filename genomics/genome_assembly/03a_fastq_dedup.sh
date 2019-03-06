#!/bin/bash -l
#PBS -N tsvsplit
#PBS -q standby
#PBS -l nodes=1:ppn=20,walltime=4:00:00,naccesspolicy=singlejob

cd $PBS_O_WORKDIR

FASTUNIQ="$RCAC_SCRATCH/tools/FastUniq/source/fastuniq"
INPUT_LIST="$RCAC_SCRATCH/list.txt"
R1_OUTPUT="$RCAC_SCRATCH/R1.dedup.fastq"
R2_OUTPUT="$RCAC_SCRATCH/R2.dedup.fastq"

${FASTUNIQ} \
    -i "${INPUT_LIST}" \
    -t q \
    -o "$R1_OUTPUT" \
    -p "$R2_OUTPUT" \
    -c 0
