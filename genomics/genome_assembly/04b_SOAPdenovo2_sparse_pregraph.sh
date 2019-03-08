#!/bin/bash -l
#PBS -N sparse_pregraph
#PBS -q mohamm20
#PBS -l nodes=1:ppn=20,walltime=336:00:00,naccesspolicy=singlejob
#PBS -l epilogue=/scratch/snyder/r/rshrote/epilogue.sh

cd $PBS_O_WORKDIR

SOAPDENOVO2="$RCAC_SCRATCH/tools/SOAPdenovo2/SOAPdenovo-127mer"
CONFIG_FILE="04_assembly.config"
KMER_SIZE=89
#KMER_SIZE=75
#KMER_SIZE=105
ESTIMATED_GENOME_SIZE=17000000000

${SOAPDENOVO2} \
    sparse_pregraph \
    -s "${CONFIG_FILE}" \
    -K ${KMER_SIZE} \
    -p $PBS_NUM_PPN \
    -z ${ESTIMATED_GENOME_SIZE} \
    -R \
    -o "sparse_pregraph_${KMER_SIZE}mer" \
    1>"sparse_pregraph_${KMER_SIZE}mer.log" \
    2>"sparse_pregraph_${KMER_SIZE}mer.err"
