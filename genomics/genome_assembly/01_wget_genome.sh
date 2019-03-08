#!/bin/bash -l
#PBS -N wget
#PBS -q standby
#PBS -l nodes=1:ppn=1,walltime=4:00:00,naccesspolicy=singleuser

################################################################################
### Script configuration variables and constants.
############################################################
### Working directory variables
# Path for working directory where genomes are to be outputted.
wrkdir="${RCAC_SCRATCH}/genomes/"
############################################################

############################################################
### Paths needed for script i/o
# Path to most recent Triticum aestivum genome.
DIRECTORY="ftp://ftp.ensemblgenomes.org/pub/plants/release-42/fasta/triticum_aestivum/"
############################################################
################################################################################



################################################################################
################################### Commands ###################################
################################################################################

############################################################
# Change working directory to the desired location
############################################################
cd "${wrkdir}"


############################################################
# Download entire wheat genome directory from Ensembl Plants.
### wget
#    Summary:
#     Retrieve web pages or files via HTTP, HTTPS or FTP.
#    Arguments (selective list):
#     -r, --recursive
#           Turn on recursive retrieving. The default maximum depth is 5.
#     -np, --no-parent
#           Don't ascend to the parent directory when downloading.
############################################################
wget -r -np "${DIRECTORY}"


# End of Operations; EOF
