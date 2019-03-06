#!/bin/bash -l
#PBS -N fastq2tsv
#PBS -q standby
#PBS -l nodes=1:ppn=2,walltime=4:00:00

cd $PBS_O_WORKDIR

forward='036570_15_S134_R1_filtered.tsv'
reverse='036570_15_S134_R2_filtered.tsv'

P1L1='^@A00218:28:HCYGTDSXX:1'
P1L2='^@A00218:28:HCYGTDSXX:2'
P1L3='^@A00218:28:HCYGTDSXX:3'
P1L4='^@A00218:28:HCYGTDSXX:4'
P2L1='^@A00218:29:HH2K3DSXX:1'
P2L2='^@A00218:29:HH2K3DSXX:2'
P2L3='^@A00218:29:HH2K3DSXX:3'
P2L4='^@A00218:29:HH2K3DSXX:4'

grep -E $P1L1 $forward > "${forward%.*}.HCYGTDSXX.1.tsv"
grep -E $P1L2 $forward > "${forward%.*}.HCYGTDSXX.2.tsv"
grep -E $P1L3 $forward > "${forward%.*}.HCYGTDSXX.3.tsv"
grep -E $P1L4 $forward > "${forward%.*}.HCYGTDSXX.4.tsv"
grep -E $P2L1 $forward > "${forward%.*}.HH2K3DSXX.1.tsv"
grep -E $P2L2 $forward > "${forward%.*}.HH2K3DSXX.2.tsv"
grep -E $P2L3 $forward > "${forward%.*}.HH2K3DSXX.3.tsv"
grep -E $P2L4 $forward > "${forward%.*}.HH2K3DSXX.4.tsv"

grep -E $P1L1 $reverse > "${reverse%.*}.HCYGTDSXX.1.tsv"
grep -E $P1L2 $reverse > "${reverse%.*}.HCYGTDSXX.2.tsv"
grep -E $P1L3 $reverse > "${reverse%.*}.HCYGTDSXX.3.tsv"
grep -E $P1L4 $reverse > "${reverse%.*}.HCYGTDSXX.4.tsv"
grep -E $P2L1 $reverse > "${reverse%.*}.HH2K3DSXX.1.tsv"
grep -E $P2L2 $reverse > "${reverse%.*}.HH2K3DSXX.2.tsv"
grep -E $P2L3 $reverse > "${reverse%.*}.HH2K3DSXX.3.tsv"
grep -E $P2L4 $reverse > "${reverse%.*}.HH2K3DSXX.4.tsv"
