#!/bin/bash -l
#PBS -N samsplit
#PBS -q standby
#PBS -l nodes=1:ppn=1,walltime=4:00:00

cd $RCAC_SCRATCH/genomes/

# load modules
module load bioinfo
module load samtools

# samtools flags
#Flag        Description
#0x0001  Paired in sequencing
#0x0002  Mapped in proper read pair
#0x0004  Query unmapped
#0x0008  Mate unmapped
#0x0010  Strand of the query (1 for reverse)
#0x0020  Strand of the mate (1 for reverse)
#0x0040  First read in the pair
#0x0080  Second read in the pair
#0x0100  Secondary alignment
#0x0200  QC failure
#0x0400  Optical or PCR duplicates

# Usage:
#   get_chr(in_sam, chr, out_sam)
function get_chr() {
    local in_sam=$1
    local chr=$2
    local out_sam=$3
    awk "{OFS=\"\t\"; if(\$1 ~ /^@/ || \$3 == \"$chr\") {print}}" $in_sam > $out_sam
}

# Paired READs sam file (PREADS_SAM)
PREADS_SAM="036570_15_S134_bwa_mem_pair_aln.sam"
PREADS_STAT="${PREADS_SAM%.*}.stat"
SPLIT_PROPER_SAM="${PREADS_SAM%.*}.proper.sam"
SPLIT_IMPROPER_SAM="${PREADS_SAM%.*}.improper.sam"
SPLIT_IMPROPER_UNMAPPED_SAM="${SPLIT_IMPROPER_SAM%.*}.unmapped.sam"
SPLIT_IMPROPER_INTERCHR_MULTICHR_SAM="${SPLIT_IMPROPER_SAM%.*}.interchr-multichr.sam"

# start by computing statistics on the paired read file
samtools flagstat $PREADS_SAM > $PREADS_STAT

# get everything that is properly paired and mapped to same chr
# put everything that is not found into another file.
# use -h to keep header
# use -U <FILE> to get everything that wasn't found the first time.
samtools view \
    -h \
    -f 3 \
    -U $SPLIT_IMPROPER_SAM \
    -o $SPLIT_PROPER_SAM

#Split our properly mapped file into multiple files based on chromosome alignment
for chr in {{1..7}{A,B,D},Un}
do
    get_chr \
        "$SPLIT_PROPER_SAM" \
        "$chr" \
        "${SPLIT_PROPER_SAM%.*}.$chr.sam"
done

# split our improperly mapped file into completely unmapped and interchromosome/multi-mapped files
samtools view \
    -h \
    -f 12 \
    -U $SPLIT_IMPROPER_INTERCHR_MULTICHR_SAM \
    -o $SPLIT_IMPROPER_UNMAPPED_SAM

# Miscellaneous commands; not used
# View only reads that are properly paired, and count the number of lines/reads:
#samtools view -f 3 my.bam | wc -l
# View only reads that are paired but mate is unmapped, excluding reads
# that are themselves unmapped, and count:
#samtools view -f 9 -F 4 my.bam | wc -l
# View only reads that are paired, unmapped and with unmapped mate, and count:
#samtools view -f 13 my.bam | wc -l
# split into first and second read.
#samtools view -f 0x40 Paired.bam > Pair_1.bam
#samtools view -f 0x80 Paired.bam > Pair_2.bam
