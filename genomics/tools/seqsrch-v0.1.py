#!/usr/bin/env python
# python 2.7

# Adapted from: https://www.biostars.org/p/209383/

from Bio import SeqIO
import os.path
import re
import sys

# How to use this script
usage = "Usage: seqsrch [OPTION]...\n\n"\
        "  Input/Output:\n"\
        "    -b, --out-bed        BED file to output search results to.\n"\
        "    -f, --in-fasta       FASTA file to search in.\n"\
        "    -s, --out-stats      File to output tab-delimited stats of search results.\n"\
        "    -q, --in-query-file  Path of file containing queries. One query per line.\n\n"\
        "  Search Options:\n"\
        "    -d, --duplicates     Do not eliminate duplicate entries and sort.\n"\
        "                         Default: Do not eliminate duplicate entries.\n"\
        "    -i, --ignore-case    Set case sensitivity to case-insensitive.\n"\
        "                         Default: Case sensitive.\n\n"\
        "  Miscellaneous:\n"\
        "    -h, --help           Print this help message.\n"


#*****************************************************************************#
# Variables required for script function

# MODIFY ME: Input file name
infasta = None

# MODIFY ME: Output file name
outbed = None

# DO NOT MODIFY: Raw outbed tab-deliminated file
outbedraw = None

# OPTIONAL: Output tab-deliminated file containing query find counts
outstats = None

# DO NOT MODIFY ME: Raw outstats file object
outstatsraw = None

# OPTIONAL: Input file containing list of query strings, one per line.
inquery = None

# DO NOT MODIFY ME: Raw inquery file object
inqueryraw = None

# MODIFY ME: List of strings to search for in the fasta sequence entries.
#   + If the search is case sensitive, they need to match exactly.
#   + If the search is not case sensitive, string case does not matter.
query = []

# DO NOT MODIFY: List of numbers containing counts of found queries
query_counts = None

# DO NOT MODIFY: List of query strings and its expansions/reverse complements.
subquery = None

# DO NOT MODIFY: List of numbers containing counts of found queries
subquery_counts = None

# MODIFY ME: boolean
#   Perform a case sensitive search?
case_sensitive = True

# MODIFY ME: boolean
#   Sort and elimitate duplicate queries
sort_elim_dups = True

# An object containing records; set it to null.
records = None

# The number of fasta entries written.
fasta_entry_count = 0

#*****************************************************************************#


#*********************************************************#
# Process command line arguments
arg = 1
state = 0
while arg < len(sys.argv):
    if state == 0:
        if sys.argv[arg] == "-b" or sys.argv[arg] == "--out-bed":
            state = 1
            arg += 1
        elif sys.argv[arg] == "-f" or sys.argv[arg] == "--in-fasta":
            state = 2
            arg += 1
        elif sys.argv[arg] == "-s" or sys.argv[arg] == "--out-stats":
            state = 3
            arg += 1
        elif sys.argv[arg] == "-q" or sys.argv[arg] == "--in-query-file":
            state = 4
            arg += 1
        elif sys.argv[arg] == "-d" or sys.argv[arg] == "--duplicates":
            sort_elim_dups = False
            arg += 1
        elif sys.argv[arg] == "-i" or sys.argv[arg] == "--ignore-case":
            case_sensitive = False
            arg += 1
        elif sys.argv[arg] == "-h" or sys.argv[arg] == "--help":
            print(usage)
            quit(0)
        else:
            print("Malformed arguments.\n")
            print(usage)
            quit(1)

    # -b, --out-bed
    elif state == 1:
        outfasta = sys.argv[arg]
        state = 0
    # -f, --in-fasta
    elif state == 2:
        infasta = sys.argv[arg]
        state = 0
    # -s, --out-stats
    elif state == 3:
        outstats = sys.argv[arg]
        state = 0
    # -q, --in-query-file
    elif state == 4:
        inquery = sys.argv[arg]
        state = 0
    else:
        print("Unknown error. Exiting.\n")
        quit(1)

if state != 0:
    print("Malformed arguments.\n")
    print(usage)
    quit(1)
#*********************************************************#


#*********************************************************#
# Perform sanity checks and make sure everything is OK.

# Make sure infasta file exists.
if infasta == None:
    print("No input FASTA file specified. Exiting.\n")
    quit(1)
if not os.path.isfile(infasta):
    print("The file %s does not exist. Exiting." % (infasta))
    quit(1)

# If query array is specified, we don't need to check for inquery
if query == None or len(query) == 0:
    # Make sure inquery file exists if it is specified.
    if inquery == None:
        print("No input query file specified. Exiting.\n")
        quit(1)
if not os.path.isfile(inquery):
    print("The file %s does not exist. Exiting." % (inquery))
    quit(1)

# Make sure we have an outbed file.
if outbed == None:
    print("No output BED file name specified. Exiting.")
    quit(1)
#*********************************************************#


#*********************************************************#
# Process input query file
with open(inquery, "r") as inqueryraw:
    for line in inqueryraw:
        query.append(line.rstrip('\n')) # strip \n and append to query list
#*********************************************************#


#*********************************************************#
# eliminate duplicates and sort the array
if sort_elim_dups == True:
    # convert query array to a set (eliminates duplicates)
    query = set(query)
    # convert set back to an array
    query = list(query)
    # sort our array
    query.sort()

# Populate the query_counts list with zeros
query_counts = [0] * len(query)

# Populate the subquery list with lists
subquery = [[]] * len(query)

# Populate the subquery with initial sequences
for i in len(query):
    subquery[i].append(query[i])

# Populate the subquery_counts list with lists
subquery_counts = [[]] * len(query)
#*********************************************************#


#*********************************************************#
# define reverse complement function
def revcomp(sequence):
    rev = sequence[::-1]
    revc = ""
    for n in range(len(rev)):
        if(rev[n] == 'A'):
            revc += 'T'
        elif(rev[n] == 'T'):
            revc += 'A'
        elif(rev[n] == 'C'):
            revc += 'G'
        elif(rev[n] == 'G'):
            revc += 'C'
        elif(rev[n] == 'a'):
            revc += 't'
        elif(rev[n] == 't'):
            revc += 'a'
        elif(rev[n] == 'c'):
            revc += 'g'
        elif(rev[n] == 'g'):
            revc += 'c'
        else:
            revc += rev[n]
    return revc
#*********************************************************#

#*********************************************************#
# Define a function to:
# Expand queries...
#   Example: ['N'] -> ['A','T','C','G']
# Add reverse complements...
#   Example: ['ATGC'] -> ['GCAT']
# Eliminate duplicates and sort
def sqexpand(subquery):
    for grp in subquery:
        s = 0
        while s < len(grp):
            i = 0
            while i < len(grp[s])
                if c == 'B':
                    grp.append( '%s%s%s'%((grp[s])[:i],'C',(grp[s])[i+1:]) )
                    grp.append( '%s%s%s'%((grp[s])[:i],'G',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'T',(grp[s])[i+1:])
                    i += 1
                elif c == 'b':
                    grp.append( '%s%s%s'%((grp[s])[:i],'c',(grp[s])[i+1:]) )
                    grp.append( '%s%s%s'%((grp[s])[:i],'g',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'t',(grp[s])[i+1:])
                    i += 1
                elif c == 'D':
                    grp.append( '%s%s%s'%((grp[s])[:i],'A',(grp[s])[i+1:]) )
                    grp.append( '%s%s%s'%((grp[s])[:i],'G',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'T',(grp[s])[i+1:])
                    i += 1
                elif c == 'd':
                    grp.append( '%s%s%s'%((grp[s])[:i],'a',(grp[s])[i+1:]) )
                    grp.append( '%s%s%s'%((grp[s])[:i],'g',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'t',(grp[s])[i+1:])
                    i += 1
                elif c == 'H':
                    grp.append( '%s%s%s'%((grp[s])[:i],'A',(grp[s])[i+1:]) )
                    grp.append( '%s%s%s'%((grp[s])[:i],'C',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'T',(grp[s])[i+1:])
                    i += 1
                elif c == 'h':
                    grp.append( '%s%s%s'%((grp[s])[:i],'a',(grp[s])[i+1:]) )
                    grp.append( '%s%s%s'%((grp[s])[:i],'c',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'t',(grp[s])[i+1:])
                    i += 1
                elif c == 'K':
                    grp.append( '%s%s%s'%((grp[s])[:i],'G',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'T',(grp[s])[i+1:])
                    i += 1
                elif c == 'k':
                    grp.append( '%s%s%s'%((grp[s])[:i],'g',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'t',(grp[s])[i+1:])
                    i += 1
                elif c == 'M':
                    grp.append( '%s%s%s'%((grp[s])[:i],'A',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'C',(grp[s])[i+1:])
                    i += 1
                elif c == 'm':
                    grp.append( '%s%s%s'%((grp[s])[:i],'a',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'c',(grp[s])[i+1:])
                    i += 1
                elif c == 'N':
                    grp.append( '%s%s%s'%((grp[s])[:i],'A',(grp[s])[i+1:]) )
                    grp.append( '%s%s%s'%((grp[s])[:i],'C',(grp[s])[i+1:]) )
                    grp.append( '%s%s%s'%((grp[s])[:i],'G',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'T',(grp[s])[i+1:])
                    i += 1
                elif c == 'n':
                    grp.append( '%s%s%s'%((grp[s])[:i],'a',(grp[s])[i+1:]) )
                    grp.append( '%s%s%s'%((grp[s])[:i],'c',(grp[s])[i+1:]) )
                    grp.append( '%s%s%s'%((grp[s])[:i],'g',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'t',(grp[s])[i+1:])
                    i += 1
                elif c == 'R':
                    grp.append( '%s%s%s'%((grp[s])[:i],'A',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'G',(grp[s])[i+1:])
                    i += 1
                elif c == 'r':
                    grp.append( '%s%s%s'%((grp[s])[:i],'a',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'g',(grp[s])[i+1:])
                    i += 1
                elif c == 'S':
                    grp.append( '%s%s%s'%((grp[s])[:i],'C',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'G',(grp[s])[i+1:])
                    i += 1
                elif c == 's':
                    grp.append( '%s%s%s'%((grp[s])[:i],'c',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'g',(grp[s])[i+1:])
                    i += 1
                elif c == 'V':
                    grp.append( '%s%s%s'%((grp[s])[:i],'A',(grp[s])[i+1:]) )
                    grp.append( '%s%s%s'%((grp[s])[:i],'C',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'G',(grp[s])[i+1:])
                    i += 1
                elif c == 'v':
                    grp.append( '%s%s%s'%((grp[s])[:i],'a',(grp[s])[i+1:]) )
                    grp.append( '%s%s%s'%((grp[s])[:i],'c',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'g',(grp[s])[i+1:])
                    i += 1
                elif c == 'W':
                    grp.append( '%s%s%s'%((grp[s])[:i],'A',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'T',(grp[s])[i+1:])
                    i += 1
                elif c == 'w':
                    grp.append( '%s%s%s'%((grp[s])[:i],'a',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'t',(grp[s])[i+1:])
                    i += 1
                elif c == 'Y':
                    grp.append( '%s%s%s'%((grp[s])[:i],'C',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'T',(grp[s])[i+1:])
                    i += 1
                elif c == 'y':
                    grp.append( '%s%s%s'%((grp[s])[:i],'c',(grp[s])[i+1:]) )
                    grp[s] = '%s%s%s'%((grp[s])[:i],'t',(grp[s])[i+1:])
                    i += 1
                else:
                    i += 1

    # add reverse complements
    for i in range(len(subquery)):
        grplen = len(subquery[i])
        for j in range(grplen):
            subquery[i].append( revcomp(subquery[i][j]) )

    # eliminate duplicates and sort
    for i in range(len(subquery)):
        subquery[i] = set(subquery[i])
        subquery[i] = list(subquery[i])
        subquery[i].sort()

#*********************************************************#


#*********************************************************#
# Expand our sequences
sqexpand(subquery)
#*********************************************************#




#*********************************************************#
# Search our fasta file for sequences
outbedraw = open(outbed, "w+")
for record in SeqIO.parse(infasta, "fasta"):
    chrom = record.id
    for i in range(len(subquery)):
        for j in range(len(subquery[i])):
            for fmatch in re.finditer(subquery[i][j], str(record.seq)):
                start_pos = fmatch.start() + 1
                end_pos = fmatch.end() + 1
                outbedraw.write("%s\t%s\t%s\t%s:%s\n" % (chrom, str(start_pos), str(end_pos), query[i], subquery[i][j]))
#*********************************************************#


# Close our output file
outbedraw.close()
