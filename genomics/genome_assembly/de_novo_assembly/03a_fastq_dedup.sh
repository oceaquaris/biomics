#!/bin/bash -l
#PBS -N fastqdedup
#PBS -q standby
#PBS -l nodes=1:ppn=20,walltime=4:00:00,naccesspolicy=singlejob
#PBS -l epilogue=/scratch/snyder/r/rshrote/epilogue.sh

cd $PBS_O_WORKDIR

FASTUNIQ="$RCAC_SCRATCH/tools/FastUniq/source/fastuniq"
INPUT_LIST="$RCAC_SCRATCH/assembly/03_dedup/set1.txt"
R1_OUTPUT="$RCAC_SCRATCH/assembly/03_dedup/dedup/set1.R1.dedup.fastq"
R2_OUTPUT="$RCAC_SCRATCH/assembly/03_dedup/dedup/set1.R2.dedup.fastq"

${FASTUNIQ} \
    -i "${INPUT_LIST}" \
    -t q \
    -o "$R1_OUTPUT" \
    -p "$R2_OUTPUT" \
    -c 0
