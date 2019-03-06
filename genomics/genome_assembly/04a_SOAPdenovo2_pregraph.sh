#!/bin/bash -l
#PBS -N pregraph
#PBS -q mohamm20
#PBS -l nodes=1:ppn=20,walltime=336:00:00,naccesspolicy=singlejob
#PBS -l epilogue=/scratch/snyder/r/rshrote/epilogue.sh

cd $PBS_O_WORKDIR

BINARY="$RCAC_SCRATCH/tools/SOAPdenovo2/SOAPdenovo-127mer"
CONFIG_FILE="$RCAC_SCRATCH/assembly/04_SOAPdenovo2/04_assembly.config"
# in GB!
INIT_MEMORY_ASSUMPTION=150
KMER_SIZE=89
#KMER_SIZE=75
#KMER_SIZE=105


${BINARY} \
    pregraph \
    -s "${CONFIG_FILE}" \
    -o "pregraph_${KMER_SIZE}mer" \
    -K ${KMER_SIZE} \
    -p $PBS_NUM_PPN \
    -a ${INIT_MEMORY_ASSUMPTION} \
    -R \
    1>"pregraph_${KMER_SIZE}mer.log" \
    2>"pregraph_${KMER_SIZE}mer.err"
