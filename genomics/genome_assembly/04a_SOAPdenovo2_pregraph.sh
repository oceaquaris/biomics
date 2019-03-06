#!/bin/bash -l
#PBS -N pregraph
#PBS -q mohamm20
#PBS -l nodes=1:ppn=20,walltime=336:00:00,naccesspolicy=singlejob
#PBS -l epilogue=/scratch/snyder/r/rshrote/epilogue.sh

cd $PBS_O_WORKDIR

BINARY="$RCAC_SCRATCH/tools/SOAPdenovo2/SOAPdenovo-127mer"
CONFIG_FILE="04_assembly.config"
KMER_SIZE=89
#KMER_SIZE=75
#KMER_SIZE=105


${BINARY} \
    pregraph \
    -s "${CONFIG_FILE}" \
    -K ${KMER_SIZE} \
    -p $PBS_NUM_PPN \
    -R \
    -o "pregraph_${KMER_SIZE}mer" \
    1>"pregraph_${KMER_SIZE}mer.log" \
    2>"pregraph_${KMER_SIZE}mer.err"
