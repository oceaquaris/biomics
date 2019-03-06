#!/bin/bash -l
#PBS -N scaffold
#PBS -q mohamm20
#PBS -l nodes=1:ppn=20,walltime=336:00:00,naccesspolicy=singlejob
#PBS -l epilogue=/scratch/snyder/r/rshrote/epilogue.sh

cd $PBS_O_WORKDIR

BINARY="$RCAC_SCRATCH/tools/SOAPdenovo2/SOAPdenovo-127mer"
CONFIG_FILE="04_assembly.config"
KMER_SIZE=89
#KMER_SIZE=75
#KMER_SIZE=105
GRAPH_PREFIX="pregraph_${KMER_SIZE}mer"

${bin} scaff -g graph_prefix -F 1>scaff.log 2>scaff.err
${BINARY} \
    scaff \
    -g "${GRAPH_PREFIX}" \
    -F \
    1>"scaffold_${KMER_SIZE}.log" \
    2>"scaffold_${KMER_SIZE}.err"
