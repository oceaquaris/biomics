#!/bin/bash -l
#PBS -N wget
#PBS -q standby
#PBS -l nodes=1:ppn=1,walltime=4:00:00

cd $RCAC_SCRATCH/genomes/

DIRECTORY="ftp://ftp.ensemblgenomes.org/pub/plants/release-42/fasta/triticum_aestivum/"

# Download entire wheat genome directory from Ensembl Plants.
wget -r -np "${DIRECTORY}"
