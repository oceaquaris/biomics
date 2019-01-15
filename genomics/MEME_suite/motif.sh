#!/bin/bash -l
#PBS -N motif_find
#PBS -q standby
#PBS -l nodes=1:ppn=1,mem=32gb,walltime=48:00:00,naccesspolicy=shared

module load bioinfo
module load meme
module load BEDTools

WRKDIR="$RCAC_SCRATCH/genomes/Triticum_aestivum/iwgsc/"

# motif sequences
ABRE="[AG][CT]ACGTGG[CT][AG]"
DRE="TACCGACAT"
ABRE_DRE="ACGTG[GT]C"
# the reference genome
REFGNM="161010_Chinese_Spring_v1.0_pseudomolecules.fa"
# reference genome annotations
ANNOBED="annotations/iwgsc_refseqv1.0_HighConf_2017Mar13.bed"

# critical files
MOTIFS="motifs.meme"
FIMOTSV="fimo.tsv"
FIMOBED="fimo.bed"
CLOSEST="closest.bed"

# change the working directory
cd "${WRKDIR}"

# make the motif file
iupac2meme "${ABRE}" "${DRE}" "${ABRE_DRE}"> "${MOTIFS}"

# search for motifs
# the --max-stored-scores 1000000 option is unneeded.
# piped straight to stdout
fimo --text "${MOTIFS}" "${REFGNM}" > "${FIMOTSV}"

# calculate q values and make a bed file
# shift indices from 1 indexed to 0 indexed and make a bed file.
# head -n -4 "./fimo_out/fimo.tsv" | \ # needed when not using --text option
qvalue --header 1 --column 8 --append "${FIMOTSV}" | \
tail -n +2 | \
awk '{printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",$3,$4-1,$5-1,$2,$7,$6,$8,$11,$1,$10)}' | \
sort -k1,1 -k2,2n -k3,3n \
> "${FIMOBED}"

# find nearest genes
bedtools closest -d -a "${FIMOBED}" -b "${ANNOBED}" > "${CLOSEST}"
