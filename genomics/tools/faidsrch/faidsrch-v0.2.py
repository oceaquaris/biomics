#!/usr/bin/env python2

# Dependencies: biopython, os.path

import os.path
from Bio import SeqIO

#*****************************************************************************#
# Variables required for script function

# MODIFY ME: Input file name
infasta = "/home/rs14/genomes/Triticum_aestivum_INRA/iwgsc_refseqv1.0_HighConf_CDS_2017Mar13.fa"

# MODIFY ME: Output file name
outfasta = "/home/rs14/genomes/Triticum_aestivum_INRA/found_root_genes2.fa"

# OPTIONAL: Output tab-deliminated file containing query find counts
outfinds = "/home/rs14/genomes/Triticum_aestivum_INRA/found_root_genes2.txt"

# DO NOT MODIFY ME: Raw outfinds file object
outfindsraw = None

# MODIFY ME: List of strings to search for in the fasta ID entries.
#   + If the search is case sensitive, they need to match exactly.
#   + If the search is not case sensitive, string case does not matter.
query = ['TraesCS4B01G287100','TraesCS4B01G366100','TraesCS4B01G382000',
'TraesCS5B01G516500','TraesCS5B01G517000','TraesCS5B01G517200',
'TraesCS5B01G517500','TraesCS6A01G093900','TraesCS7A01G433000',
'TraesCS7A01G555100','TraesCS7A01G555200','TraesCS7A01G555300',
'TraesCS7D01G412500','TraesCS7D01G412900','TraesCS7D01G413000',
'TraesCS7D01G413300','TraesCS7D01G413400','TraesCS7D01G422300',
'TraesCS7D01G422400','TraesCS7D01G422500','TraesCS7D01G426400',
'TraesCS7D01G428200','TraesCS7D01G428800','TraesCS7D01G429400',
'TraesCS7D01G429700','TraesCS7D01G429900','TraesCS7D01G430700',
'TraesCS7D01G431000','TraesCS7D01G431800','TraesCS7D01G431900',
'TraesCS7D01G432700','TraesCS7D01G432800','TraesCS7D01G436800',
'TraesCS7D01G442000','TraesCS7D01G442000','TraesCS7D01G442000',
'TraesCS7D01G443600','TraesCS7D01G443700','TraesCS7D01G444300',
'TraesCS7D01G444600','TraesCS7D01G446900','TraesCS7D01G447000',
'TraesCS7D01G449900','TraesCS7D01G450100','TraesCS7D01G451700',
'TraesCS7D01G452100','TraesCS7D01G452500','TraesCS7D01G452500',
'TraesCS7D01G458900','TraesCS7D01G470000','TraesCS7D01G474200',
'TraesCS7D01G474300','TraesCS7D01G475100','TraesCS7D01G477600',
'TraesCS7D01G477600','TraesCS7D01G480500','TraesCS7D01G480600',
'TraesCS7D01G490100','TraesCS7D01G490600','TraesCS7D01G491000',
'TraesCS7D01G491100','TraesCS7D01G499900','TraesCS7D01G499900',
'TraesCS7D01G503100','TraesCS7D01G506200','TraesCS7D01G506200',
'TraesCS7D01G506200','TraesCS7D01G506400','TraesCS7D01G506500',
'TraesCS7D01G506700','TraesCS7D01G506800','TraesCS7D01G506800',
'TraesCS7D01G508700','TraesCS7D01G508700','TraesCS7D01G508800',
'TraesCS7D01G508800','TraesCS7D01G513500','TraesCS7D01G514700',
'TraesCS7D01G514700','TraesCS7D01G515100','TraesCS7D01G515300',
'TraesCS7D01G519200','TraesCS7D01G521400','TraesCS7D01G538600',
'TraesCS7D01G544700','TraesCS7D01G546300','TraesCS7D01G548500',
'TraesCS7D01G550500','TraesCS7D01G550800','TraesCS7D01G552200']

# DO NOT MODIFY: List of numbers containing counts of found queries
query_counts = None

# MODIFY ME: boolean
#   Perform a case sensitive search?
case_sensitive = False

# MODIFY ME: boolean
#   Sort and elimitate duplicate gene names
sort_elim_dups = True

# An object containing records; set it to null.
records = None

# The number of fasta entries written.
fasta_entry_count = 0

#*****************************************************************************#


#*********************************************************#
# Process command line arguments

#*********************************************************#


#*********************************************************#
# Perform sanity checks and make sure everything is OK.

# Make sure infasta file exists
if not os.path.isfile(infasta):
    print("The file %s does not exist. Exiting." % (infasta))
    quit()

# Make sure outfasta is OK
if outfasta == None:
    print("The output fasta file is not specified. Exiting.")
    quit()
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

# Write to outfinds
if outfinds != None:
    # open/create file
    outfindsraw = open(outfinds, "w+")
    # write header
    outfindsraw.write("%s\t%s\n" % ("Query", "Count"))
    # write counts
    for i in range(len(query)):
        outfindsraw.write("%s\t%s\n" % (query[i], query_counts[i]))
    # close file
    outfindsraw.close()

# Print how much we wrote
print("Saved %i records from %s to %s" % (fasta_entry_count, infasta, outfasta))
