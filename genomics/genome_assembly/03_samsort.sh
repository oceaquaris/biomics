#!/bin/bash -l
#PBS -N samsort
#PBS -q standby
#PBS -l nodes=1:ppn=1,walltime=4:00:00,,mem=128gb,naccesspolicy=singlejob

module load bioinfo
module load picard-tools

cd $PBS_O_WORKDIR

for file in 036570_15_S134_bwa_mem_pair_aln.proper.{{1..7}{A,B,D},Un}.sam
do
    # give ourselves plenty of memory
    java -jar -Xms64g -Xmx120g picard.jar SortSam \
        INPUT="$file" \
        OUTPUT="${file%.*}.bam" \
        SORT_ORDER=coordinate
done
