#!/bin/bash -l
#PBS -N interpro
#PBS -q standby
#PBS -l nodes=1:ppn=20,walltime=4:00:00

# Load modules
module load bioinfo java/8

WRK_DIR="$RCAC_SCRATCH/genomes/Triticum_aestivum/ensembl_IWSGC/pep"
IPS_DIR="$RCAC_SCRATCH/tools/interproscan-5.33-72.0"

cd "${WRK_DIR}"

for file in ${WRK_DIR}/Triticum_aestivum.IWGSC.pep.all.{00..39}.fa
do
    $IPS_DIR/interproscan.sh\
        --cpu $PBS_NUM_PPN \
        -i $file \
        -f tsv \
        -o "${file}.interproscan-5.33-72.0.tsv"
done
