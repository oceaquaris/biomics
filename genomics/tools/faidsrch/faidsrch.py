#!/usr/bin/env python2
# version 0.5

# Dependencies: biopython, os.path

import sys
import os.path
from Bio import SeqIO

#*****************************************************************************#
# Variables required for script function

# MODIFY ME: Input file name
infasta = None

# MODIFY ME: Output file name
outfasta = None

# OPTIONAL: Output tab-deliminated file containing query find counts
outstats = None

# DO NOT MODIFY ME: Raw outstats file object
outstatsraw = None

# OPTIONAL: Input file containing list of query strings, one per line.
inquery = None

# DO NOT MODIFY ME: Raw inquery file object
inqueryraw = None

# MODIFY ME: List of strings to search for in the fasta ID entries.
#   + If the search is case sensitive, they need to match exactly.
#   + If the search is not case sensitive, string case does not matter.
query = []

# DO NOT MODIFY: List of numbers containing counts of found queries
query_counts = None

# MODIFY ME: boolean
#   Perform a case sensitive search?
case_sensitive = True

# MODIFY ME: boolean
#   Sort and elimitate duplicate gene names
sort_elim_dups = False

# An object containing records; set it to null.
records = None

# The number of fasta entries written.
fasta_entry_count = 0

#*****************************************************************************#


#*********************************************************#
# Process command line arguments
usage = "Usage: faidsrch [OPTION]...\n\n"\
        "  Input/Output:\n"\
        "    -f, --in-fasta       FASTA file to search in.\n"\
        "    -o, --out-fasta      FASTA file to output search results to.\n"\
        "    -s, --out-stats      File to output tab-delimited stats of search results.\n"\
        "    -q, --in-query-file  Path of file containing queries. One query per line.\n\n"\
        "  Search Options:\n"\
        "    -e, --elim-dups-sort Eliminate duplicate entries and sort.\n"\
        "                         Default: Do not eliminate duplicate entries.\n"\
        "    -i, --ignore-case    Set case sensitivity to case-insensitive.\n"\
        "                         Default: Case sensitive.\n\n"\
        "  Miscellaneous:\n"\
        "    -h, --help           Print this help message.\n"

arg = 1
state = 0
while arg < len(sys.argv):
    if state == 0:
        if sys.argv[arg] == "-f" or sys.argv[arg] == "--in-fasta":
            state = 1
            arg += 1
        elif sys.argv[arg] == "-o" or sys.argv[arg] == "--out-fasta":
            state = 2
            arg += 1
        elif sys.argv[arg] == "-s" or sys.argv[arg] == "--out-stats":
            state = 3
            arg += 1
        elif sys.argv[arg] == "-q" or sys.argv[arg] == "--in-query-file":
            state = 4
            arg += 1
        elif sys.argv[arg] == "-e" or sys.argv[arg] == "--elim-dups-sort":
            sort_elim_dups = True
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

    # -f, --in-fasta
    elif state == 1:
        infasta = sys.argv[arg]
        state = 0
        arg += 1
    # -o, --out-fasta
    elif state == 2:
        outfasta = sys.argv[arg]
        state = 0
        arg += 1
    # -s, --out-stats
    elif state == 3:
        outstats = sys.argv[arg]
        state = 0
        arg += 1
    # -q, --in-query-file
    elif state == 4:
        inquery = sys.argv[arg]
        state = 0
        arg += 1
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

# Make sure inquery file exists if it is specified.
if inquery != None:
    if not os.path.isfile(inquery):
        print("The file %s does not exist. Exiting." % (inquery))
        quit(1)

# Make sure outfasta is OK
if outfasta == None:
    print("The output fasta file is not specified. Exiting.")
    quit()
#*********************************************************#


#*********************************************************#
# Process input query file
with open(inquery, "r") as inqueryraw:
    for line in inqueryraw:
        if len(line.rstrip('\n')) > 0:
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
#*********************************************************#


#*********************************************************#
# Memory efficient Python generator function
def find_entry(infasta, qList, qcList, caseSensitive):
    for r in SeqIO.parse(infasta, "fasta"):
        identifier = r.id if caseSensitive == True else r.id.upper()
        for q in xrange(len(qList)):
            seq = qList[q] if caseSensitive == True else qList[q].upper()
            if identifier.find(seq) != -1:
                qcList[q] += 1
                yield r
#*********************************************************#


# Find our fasta entries!
records = find_entry(infasta, query, query_counts, case_sensitive)

# Write to outfasta
fasta_entry_count = SeqIO.write(records, outfasta, "fasta")

# Write to outstats
if outstats != None:
    # open/create file
    outstatsraw = open(outstats, "w+")
    # write header
    outstatsraw.write("%s\t%s\n" % ("Query", "Count"))
    # write counts
    for i in range(len(query)):
        outstatsraw.write("%s\t%s\n" % (query[i], query_counts[i]))
    # close file
    outstatsraw.close()

# Print how much we wrote
print("Saved %i records from %s to %s" % (fasta_entry_count, infasta, outfasta))
