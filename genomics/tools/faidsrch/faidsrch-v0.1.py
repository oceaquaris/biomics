#!/usr/bin/env python2

# Dependencies: biopython, os.path

import os.path
from Bio import SeqIO

#*****************************************************************************#

# MODIFY ME: Input file name
input_file = "/path/to/my/fasta/file/genes.fa"

# MODIFY ME: Output file name
output_file = "/path/to/my/output/fasta/file/found_genes.fa"

# MODIFY ME: List of strings to search for in the fasta ID entries.
#   + If the search is case sensitive, they need to match exactly.
#   + If the search is not case sensitive, string case does not matter.
genes = ['Gene01','Gene02',
         'Gene03','Gene04',]

# MODIFY ME: boolean
#   Perform a case sensitive search?
case_sensitive = False

#*****************************************************************************#



#*********************************************************#
# Do a sanity check and make sure our file exists.
file_exists = os.path.isfile(input_file)
if not file_exists:
    print("The file %s does not exist. Exiting." % (input_file))
    quit()
#*********************************************************#


# An object containing records; set it to null.
records = None

# The number of fasta entries written.
count = 0


#*********************************************************#
# Acquire records using a memory efficient Python generator expression.
if case_sensitive == True:
    print("Performing a case sensitive search in %s" % (input_file))
    records = (r for r in SeqIO.parse(input_file, "fasta") if any(g in r.id for g in genes))
elif case_sensitive == False:
    print("Performing a case insensitive search in %s" % (input_file))
    records = (r for r in SeqIO.parse(input_file, "fasta") if any(g.upper() in r.id.upper() for g in genes))
else:
    print("case_sensitive = %s" % (case_sensitive))
    print("Case sensitivity option not set to 'True' or 'False'. Exiting.")
    quit()
#*********************************************************#


# Write to output_file
count = SeqIO.write(records, output_file, "fasta")

# Print how much we wrote
print("Saved %i records from %s to %s" % (count, input_file, output_file))
