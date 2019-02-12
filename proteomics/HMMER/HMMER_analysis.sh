#!/bin/bash -l
#PBS -N HMMER
#PBS -q standby
#PBS -l nodes=1:ppn=4,walltime=00:30:00,naccesspolicy=singleuser
#PBS -l epilogue=/depot/jwisecav/darwin/queue_stuff/epilogue.sh

# change directory to from where script was submitted.
cd $PBS_O_WORKDIR

# load modules
module load bioinfo
module load HMMER

# Retrieve genomes
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-42/fasta/triticum_aestivum/pep/Triticum_aestivum.IWGSC.pep.all.fa.gz
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-42/fasta/arabidopsis_thaliana/pep/Arabidopsis_thaliana.TAIR10.pep.all.fa.gz

# unzip the gzip files.
gunzip \
    Triticum_aestivum.IWGSC.pep.all.fa.gz \
    Arabidopsis_thaliana.TAIR10.pep.all.fa.gz

# perform HMMER analysis; search Triticum_aestivum against Arabidopsis_thaliana
phmmer \
    --cpu $PBS_NUM_PPN \
    --tblout "Baphidicola_v_Ecoli.phmmer.out" \
    Triticum_aestivum.IWGSC.pep.all.fa \
    Arabidopsis_thaliana.TAIR10.pep.all.fa
