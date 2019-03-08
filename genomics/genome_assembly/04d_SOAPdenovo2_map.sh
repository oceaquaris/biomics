#!/bin/bash -l
#PBS -N map
#PBS -q mohamm20
#PBS -l nodes=1:ppn=20,walltime=336:00:00,naccesspolicy=singlejob
#PBS -l epilogue=/scratch/snyder/r/rshrote/epilogue.sh

cd $PBS_O_WORKDIR

SOAPDENOVO2="$RCAC_SCRATCH/tools/SOAPdenovo2/SOAPdenovo-127mer"
CONFIG_FILE="04_assembly.config"
KMER_SIZE=89
#KMER_SIZE=75
#KMER_SIZE=105
GRAPH_PREFIX="pregraph_${KMER_SIZE}mer"

${SOAPDENOVO2} \
    map \
    -s "${CONFIG_FILE}" \
    -g "${GRAPH_PREFIX}" \
    1>"map_${KMER_SIZE}.log" \
    2>"map_${KMER_SIZE}.err"
