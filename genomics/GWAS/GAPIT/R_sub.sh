#!/bin/bash -l
# Name of Job Submission.
#PBS -N GAPIT_CMLM
# MODIFY ME: Your custum queue.
#PBS -q standby
# MODIFY ME: The number of nodes and cores you want to use.
#PBS -l nodes=1:ppn=2
# MODIFY ME: The amount of memory you want reserved for the job.
#PBS -l mem=16gb
# MODIFY ME: The walltime for your job.
#PBS -l walltime=24:00:00
# MODIFY ME: The node access policy for your job.
#PBS -l naccesspolicy=shared


###############################################################################
# Script variables

# MODIFY ME: Path to R working directory (the directory of this script)
Rwd="/path/to/script/working/directory"

# OPTIONAL MODIFICATION:
# + Path to local R library directory (for downloading packages off the internet)
# + This directory is the place packages will be downloaded into when R runs.
#     The location of this directory is user defined and is not special.
Rlibs="${Rwd}/Rlibs"

# MODIFY ME: Path to GAPIT R script
# MODIFY ME: There are additional modifications that need to be made within the
#            R script. See the R script for details.
r_script="${Rwd}/GAPIT_CMLM.R"
###############################################################################


###############################################################################
# Verify that our Rlibs directory exists
# if ${Rlibs} does not exist, create it and echo that it was created
if [! -e "${Rlibs}"]; then
    mkdir "${Rlibs}"
    echo "mkdir ${Rlibs}"
fi
###############################################################################


###############################################################################
# Export Rlibs to R_LIBS the user's environmental variable.
# + This is needed to prevent errors with file access permissions.
# + R packages downloaded from the internet will be routed into the directory
#     specified by this environmental variable.
export R_LIBS="${Rlibs}/"
###############################################################################


###############################################################################
# MODIFY ME: Load necessary cluster module listings here.
# e.g.:
#   module use /apps/group/bioinfo/modules

# Load our R module
# Alternatively: module load R/<version>
#   (Replace <version> with R version to load; e.g. R/3.4.2)
module load R
###############################################################################


# Execute our script
Rscript "${r_script}"
