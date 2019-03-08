#!/bin/bash -l
#PBS -N name_of_job
#PBS -q standby
#PBS -l nodes=1:ppn=1,mem=8gb,walltime=4:00:00,naccesspolicy=singleuser

# Brief How-To:
# Request computing time using PBS (should be in script header)
# Job name:
#   -N name_of_job
# Which queue to use (depends on your access privileges):
#   -q standby
# How many processing cores are needed (depends on how many nodes you have
# access to and the number of cores per node):
#   -l nodes=1:ppn=1
# How much memory must be reserved for this job (does not have to be specified):
#   -l mem=8gb
# Set max compute time (depends on your usage privileges)
#   -l walltime=120:00:00



# Load necessary modules
#module load bioinfo



################################################################################
### Script configuration variables and constants.
############################################################
### Working directory variables
# Path for working directory
wrkdir="${RCAC_SCRATCH}"
############################################################


############################################################
### Misc. variables
# Whether we are debugging
debug=1
# A temporary variable used to store the exit success of a command
tmpexit=0
# Extract the job id number from the PBS_JOBID
scriptJobID=$(echo "${PBS_JOBID}" | tr -dc '0-9')
############################################################

############################################################
### Directories needed for script i/o

############################################################


############################################################
### Paths needed for script i/o

############################################################


############################################################
### Script constants

############################################################
################################################################################



################################################################################
### Functions
############################################################
# Usage: psec2time $startsec $endsec
psec2time() {
    local secdiff=$(($2 - $1))
    local hours=$(($secdiff / 3600))
    local hoursrem=$(($secdiff % 3600))
    local minutes=$(($hoursrem / 60))
    local seconds=$(($hoursrem % 60))
    printf "%s hr %s min %s sec\n" ${hours} ${minutes} ${seconds}
}
############################################################


############################################################
# Global variables required for logfile_initialize and logfile_terminate
debug_logfile=1         # Whether we are writing to a debug logfile.
logfile_dir="${wrkdir}" # directory for logfile
logfile=''              # Path to the logfile
starttime=''            # The initialization date and time for this script
startsec=0              # The start time for this script in seconds
############################################################
# Summary: Initialize logfile variables and append the header to the logfile
# Usage: logfile_initialize
logfile_initialize() {
    # Set the name of the logfile
    logfile="${logfile_dir}/${PBS_JOBNAME}_${scriptJobID}.log"
    starttime=$(date)         # Retrieve ths start date and time
    startsec=$(date +"%s")    # Retrieve the start time in seconds
    # Append header
    echo -e "Script initialized: ${starttime}" >> ${logfile}
}
############################################################


############################################################
# Summary: Add footer to the logfile
# Usage: logfile_terminate
logfile_terminate() {
    local endtime=$(date)
    local endsec=$(date +"%s")
    echo "Script terminated: ${endtime}" >> ${logfile}
    printf "Total run time: " >> ${logfile}
    psec2time $startsec $endsec >> ${logfile}
    printf "\n"
    echo "Param\tDesc\tValue\n" \
         "\$1\tJob ID\t$1\n" \
         "\$2\tUser Name\t$2\n" \
         "\$3\tGroup Name\t$3\n" \
         "\$4\tJob Name\t$4\n" \
         "\$5\tSession ID\t$5\n" \
         "\$6\tResources Requested\t$6\n" \
         "\$7\tResources Used\t$7\n" \
         "\$8\tQueue\t$8\n" \
         "\$9\tJob Account\t$9\n" \
         "\$10\tJob exit status\t${10}" >> ${logfile}
}
############################################################


# Global variables required for stopwatch_start and stopwatch_stop
tmpstart=0
tmpend=0


############################################################
# Usage: stopwatch_start
stopwatch_start() {
    # start get the start time in secs
    tmpstart=$(date +"%s")
}
############################################################


############################################################
# Usage: stopwatch_stop $message
stopwatch_stop() {
    # get the end time in secs
    tmpend=$(date +"%s")
    # calculate hours, minutes, seconds
    local secdiff=$(($tmpend - $tmpstart))
    local hours=$(($secdiff / 3600))
    local hoursrem=$(($secdiff % 3600))
    local minutes=$(($hoursrem / 60))
    local seconds=$(($hoursrem % 60))
    printf "%s%s hr %s min %s sec\n\n" "$1" ${hours} ${minutes} ${seconds}
}
############################################################
################################################################################



################################################################################
######################## Begin Computational Protocols #########################
################################################################################



############################################################
# Begin logfile
############################################################
if [ "${debug_logfile}" -eq "1" ]
then
    logfile_initialize
fi


############################################################
# End logfile
############################################################
if [ "${debug_logfile}" -eq "1" ]
then
    logfile_terminate
fi
# End of Operations; EOF
