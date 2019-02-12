#!/bin/bash -l
#PBS -N proteome
#PBS -q scholar
#PBS -l nodes=1:ppn=4,walltime=4:00:00

WRK_DIR="$PBS_O_WORKDIR"
MAX_EVALUE="1e-3"

# load modules
module load bioinfo
module load blast

# change directory to our working directory
cd "${WRK_DIR}"

# retrieve sample proteomes
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-42/fasta/triticum_aestivum/pep/Triticum_aestivum.IWGSC.pep.all.fa.gz
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-42/fasta/arabidopsis_thaliana/pep/Arabidopsis_thaliana.TAIR10.pep.all.fa.gz

# unzip the gzip files.
gunzip \
    Triticum_aestivum.IWGSC.pep.all.fa.gz \
    Arabidopsis_thaliana.TAIR10.pep.all.fa.gz

# perform of B. aphidicola proteins onto E. coli proteins
blastp \
    -query Triticum_aestivum.IWGSC.pep.all.fa \
    -subject Arabidopsis_thaliana.TAIR10.pep.all.fa \
    -num_threads $PBS_NUM_PPN \
    -evalue $MAX_EVALUE \
    -outfmt 6 \
    -out Triticum_aestivum_vs_Arabidopsis_thaliana.tsv

# calculate number of unique hits
cat Triticum_aestivum_vs_Arabidopsis_thaliana.tsv | \
    cut -f 2 | \
    cut -d '.' -f 1 | \
    sort --unique | \
    wc -l > unique_hit_num.txt
