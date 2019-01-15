#!/bin/bash -l
# Name of Job Submission.
#PBS -N gene_find
# MODIFY ME: Your custum queue.
#PBS -q standby
# MODIFY ME: The number of nodes and cores you want to use.
#PBS -l nodes=1:ppn=1
# MODIFY ME: The amount of memory you want reserved for the job.
#PBS -l mem=8gb
# MODIFY ME: The walltime for your job.
#PBS -l walltime=4:00:00
# MODIFY ME: The node access policy for your job.
#PBS -l naccesspolicy=shared

# version 0.3

###############################################################################
# Load necessary modules

# MODIFY ME: path to directory of module entries (e.g. /apps/group/bioinfo/modules).
module load bioinfo

# Load bedops, the tool this script will be using.
module load bedops BEDTools
###############################################################################


###############################################################################
# Print script start time.
echo "Start: $(date +"%s")"
###############################################################################


###############################################################################
# Script Variables

# MODIFY ME:
#  + Scratch workspace directory.
#  + e.g. "${RCAC_SCRATCH}"
scratchwd="/path/to/scratch/directory"

# MODIFY ME:
#  + Path to directory containing gene annotation file and SNP bed file
genefindwd="${scratchwd}/path/to/annotation/directory"


### MODIFY ME: genes_gtf, genes_gff, or genes_bed
###  + At least one *.gtf, *.gff, or *.bed file path (below) needs to be specified.
###  + These files should contain all the genes in the genome.

# OPTIONAL MODIFICATION:
#  + Path to a gene annotation file in the *.gtf format.
#  + e.g. "${genefindwd}/genes.gtf"
#  + Replace with 0 if you do not have a *.gtf file available.
genes_gtf=0

# OPTIONAL MODIFICATION:
#  + Path to a gene annotation file in the *.gff format.
#  + e.g. "${genefindwd}/genes.gff"
#  + Replace with 0 if you do not have a *.gff file available.
genes_gff=0

# OPTIONAL MODIFICATION:
#  + Path to a gene annotation file in the *.bed format.
#  + e.g. "${genefindwd}/genes.bed"
#  + Replace with 0 if you do not have a *.bed file available.
genes_bed=0

# MODIFY ME:
#  + A *.bed file containing SNP ranges to extract genes from.
#  + e.g. "${genefindwd}/snp_ranges.bed"
snps_bed="${genefindwd}/name_of_bed_file.bed"

# MODIFY ME: The base name of an output file (make sure the name is unique).
#  + This is a string variable.
#  + The extension of the output file depends on this script's inputs.
#  + e.g. "found_genes"
fgenes_bname="found_genes"

# MODIFICATION NOT NECESSARY:
#  + Names of intermediate and/or output files.
fgenes_bed="${genefindwd}/${fgenes_bname}.bed"
fgenes_gtf="${genefindwd}/${fgenes_bname}.gtf"
fgenes_gff="${genefindwd}/${fgenes_bname}.gff"
###############################################################################



###############################################################################
# Make sure we have a SNP ranges *.bed file.
if [[ ! -e "${snps_bed}" ]]; then
    printf "%s does not exist.\n" "${snps_bed}"
    echo "Exiting."
    exit 1
fi
###############################################################################



###############################################################################
# Process data

# We prefer to use the *.gtf file over the *.gff file because *.gtf files are
# standardized.
# NOTE: If gtf2bed fails, it is probably because the input file is not gtf compliant.
if [[ -e "${genes_gtf}" ]]; then
    # Extract pure file name from ${genes_gtf} and store into an intermediate file name.
    bname=$(basename ${genes_gtf})
    fname=${bname%.*}
    igenes_bed="${genefindwd}/${fname}.bed"

    # Convert *.gtf to *.bed
    gtf2bed < "${genes_gtf}" > "${igenes_bed}"

    # find genes around SNP locations. Report SNP range and gene overlap.
    bedtools intersect -wa -wb -a "${snps_bed}" -b "${igenes_bed}" -sorted > "${fgenes_bed}"

# Search for a *.gff file if there is no *.gtf file.
# NOTE: If gff2bed fails, it is probably because the input file is not gff compliant.
elif [[ -e "${genes_gff}" ]]; then
    # Extract pure file name from ${genes_gff} and store into an intermediate file name.
    bname=$(basename ${genes_gtf})
    fname=${bname%.*}
    igenes_bed="${genefindwd}/${fname}.bed"

    # Convert *.gff to *.bed
    gff2bed < "${genes_gff}" > "${igenes_bed}"

    # find genes around SNP locations.
    bedtools intersect -wa -wb -a "${snps_bed}" -b "${igenes_bed}" -sorted > "${fgenes_bed}"

# Search for a *.bed file if ther is no *.gtf or *.gff file.
# NOTE: This is a pretty robust process. Only the first three columns of bed file
#       compliance are needed.
elif [[ -e "${genes_bed}" ]]; then
    # Find genes around SNP locations. Report SNP range and gene overlap.
    bedtools intersect -wa -wb -a "${snps_bed}" -b "${genes_bed}" -sorted > "${fgenes_bed}"

# Print error messages otherwise.
else
    echo "No *.gtf, *.gff, or *.bed file found. A path may not be properly defined."
    echo "Exiting."
    exit 1
fi
###############################################################################



###############################################################################
# Print script end time.
echo "End: $(date +"%s")"
###############################################################################

# EOF
