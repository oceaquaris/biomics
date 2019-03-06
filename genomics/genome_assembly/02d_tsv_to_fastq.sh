#!/bin/bash -l
#PBS -N tsvsplit
#PBS -q standby
#PBS -l nodes=1:ppn=1,walltime=4:00:00

cd $PBS_O_WORKDIR

forward='036570_15_S134_R1_filtered.tsv'
reverse='036570_15_S134_R2_filtered.tsv'

P1L1="${forward%.*}.HCYGTDSXX.1.tsv"
P1L2="${forward%.*}.HCYGTDSXX.2.tsv"
P1L3="${forward%.*}.HCYGTDSXX.3.tsv"
P1L4="${forward%.*}.HCYGTDSXX.4.tsv"
P2L1="${forward%.*}.HH2K3DSXX.1.tsv"
P2L2="${forward%.*}.HH2K3DSXX.2.tsv"
P2L3="${forward%.*}.HH2K3DSXX.3.tsv"
P2L4="${forward%.*}.HH2K3DSXX.4.tsv"

P1L1="${reverse%.*}.HCYGTDSXX.1.tsv"
P1L2="${reverse%.*}.HCYGTDSXX.2.tsv"
P1L3="${reverse%.*}.HCYGTDSXX.3.tsv"
P1L4="${reverse%.*}.HCYGTDSXX.4.tsv"
P2L1="${reverse%.*}.HH2K3DSXX.1.tsv"
P2L2="${reverse%.*}.HH2K3DSXX.2.tsv"
P2L3="${reverse%.*}.HH2K3DSXX.3.tsv"
P2L4="${reverse%.*}.HH2K3DSXX.4.tsv"

FILES="$P1L1 $P1L2 $P1L3 $P1L4 $P2L1 $P2L2 $P2L3 $P2L4 $P1L1 $P1L2 $P1L3 $P1L4 $P2L1 $P2L2 $P2L3 $P2L4"

for file in $FILES
do
    cat $file | tr '\t' '\n' > "${file%.*}.fastq"
done
