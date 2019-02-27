#!/bin/bash -l
#PBS -N blast2bed
#PBS -q standby
#PBS -l nodes=1:ppn=20,walltime=04:00:00,naccesspolicy=singlejob

WRKDIR=$PBS_O_WORKDIR
QUERY_FILE="$WRKDIR/query.fa"
MAX_HITS=1
BLAST_HITS="${QUERY_FILE%.*}.hits"
BLAST_BED="${QUERY_FILE%.*}.bed"

# change directory to working directory
cd $WRKDIR

# load modules
module load bioinfo
module load blast

# download the latest wheat genome and unzip
wget ftp://ftp.ensemblgenomes.org/pub/release-42/plants/fasta/triticum_aestivum/dna/Triticum_aestivum.IWGSC.dna.toplevel.fa.gz
gunzip Triticum_aestivum.IWGSC.dna.toplevel.fa.gz

# blast against the reference genome
# switch to -task "blastn-short" if residues are less than 50 nt
blastn \
    -query $QUERY_FILE \
    -subject Triticum_aestivum.IWGSC.dna.toplevel.fa \
    -max_target_seqs $MAX_HITS \
    -outfmt 6 \
    -out $BLAST_HITS \
    -num_threads $PBS_NUM_PPN

# process blast hits by awk
awk '{if($9 <= $10)
        {print($2"\t"$9-1"\t"$10-1"\t"$1"\t"$11"\t"$12"\t\+\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$11)}
      else
        {print($2"\t"$10-1"\t"$9-1"\t"$1"\t"$11"\t"$12"\t\-\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$11)}
    }' $BLAST_HITS > $BLAST_BED
