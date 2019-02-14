#!/bin/bash -l
#PBS -N bwa_index
#PBS -q mohamm20
#PBS -l nodes=1:ppn=1,walltime=48:00:00

cd $RCAC_SCRATCH/genomes/Triticum_aestivum/ensembl_IWSGC/dna_index/

module load bioinfo
module load bwa/0.7.17

bwa index -a bwtsw -p "Triticum_aestivum.IWGSC.dna.toplevel" Triticum_aestivum.IWGSC.dna.toplevel.fa
