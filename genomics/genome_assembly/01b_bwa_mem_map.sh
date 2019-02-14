#!/bin/bash -l
#PBS -N bwa_mem
#PBS -q mohamm20
#PBS -l nodes=1:ppn=20,walltime=96:00:00

REF_INDEX="$RCAC_SCRATCH/genomes/Triticum_aestivum/ensembl_IWSGC/dna_index/Triticum_aestivum.IWGSC.dna.toplevel"
READ_GROUP='@RG\tID:autopooled\tSM:Purdue\tPL:Illumina\tLB:lib1\tPU:unit1'
BWA_THREADS=$PBS_NUM_PPN
READ1="036570_15_S134_R1_filtered.fastq"
READ2="036570_15_S134_R2_filtered.fastq"
ALIGNED="036570_15_S134_bwa_mem_pair_aln.sam"


cd "$RCAC_SCRATCH/assembly/"

module load bioinfo
module load bwa/0.7.17

bwa mem -M -R "${READ_GROUP}" -t $BWA_THREADS "${REF_INDEX}" "${READ1}" "${READ2}" > "${ALIGNED}"
