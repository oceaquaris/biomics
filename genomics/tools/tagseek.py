#!/usr/bin/env python2
# version 0.1
# Dependencies: sys, os.path

import copy
import sys
import os.path
from array import *

#*****************************************************************************#
# Variables required for script function

# MODIFY ME: Input TASSEL sam file name
in_sam = None

# DO NOT MODIFY ME: Raw input TASSEL sam file
in_sam_raw = None

# MODIFY ME: Input TASSEL tag taxa distribution file name
in_tagtaxadist = None

# DO NOT MODIFY ME: Raw input TASSEL tag taxa distribution file
in_tagtaxadist_raw = None

# MODIFY ME: Output tab-deliminated file containing alignment and tag taxa info
out_tagpos = None

# DO NOT MODIFY ME: Raw output tab-deliminated file containing alignment and tag taxa info
out_tagpos_raw = sys.stdout

# MODIFY ME ONLY WHEN NEEDED: Array data type to store distribution counts in.
#   + Use the smallest size needed to reduce memory consumption!
#   Codes:
#        Type code |       C Type       |    Python Type    | Minimum size in bytes
#       -----------+--------------------+-------------------+-----------------------
#           'b'    | signed char        |        int        |           1
#           'B'    | unsigned char      |        int        |           1
#           'u'    | Py_UNICODE         | Unicode character |           2
#           'h'    | signed short       |        int        |           2
#           'H'    | unsigned short     |        int        |           2
#           'i'    | signed int         |        int        |           2
#           'I'    | unsigned int       |        int        |           2
#           'l'    | signed long        |        int        |           4
#           'L'    | unsigned long      |        int        |           4
#           'q'    | signed long long   |        int        |           8
#           'Q'    | unsigned long long |        int        |           8
#           'f'    | float              |       float       |           4
#           'd'    | double             |       float       |           8
typecode = 'H'
#*****************************************************************************#



#*****************************************************************************#
# Variables containing file data

# A list containing tag sequences
tags = list()

# A list containing taxa names.
taxa = list()

# A list containing arrays of tag taxa information.
distributions = list()
#*****************************************************************************#



#*****************************************************************************#
# Functions required for script function

#*********************************************************#
# partition list to be sorted
def partition(tag_list, distribution_list, first, last):
    pivotstr = tag_list[first]

    leftmark = first + 1
    rightmark = last

    done = False
    while not done:
        while leftmark <= rightmark and tag_list[leftmark] <= pivotstr:
            leftmark += 1

        while tag_list[rightmark] >= pivotstr and rightmark >= leftmark:
            rightmark -= 1

        if rightmark < leftmark:
            done = True
        else:
            # alter tag_list
            tmpstr = tag_list[leftmark]
            tag_list[leftmark] = tag_list[rightmark]
            tag_list[rightmark] = tmpstr
            # alter distribution_list
            tmparr = distribution_list[leftmark]
            distribution_list[leftmark] = distribution_list[rightmark]
            distribution_list[rightmark] = tmparr

    # alter tag_list
    tmpstr = tag_list[first]
    tag_list[first] = tag_list[rightmark]
    tag_list[rightmark] = tmpstr
    # alter distribution_list
    tmparr = distribution_list[first]
    distribution_list[first] = distribution_list[rightmark]
    distribution_list[rightmark] = tmparr

    return rightmark
#*********************************************************#


#*********************************************************#
# helper function for quickSort
def quickSortHelper(tag_list, distribution_list, first, last):
    if first < last:
        splitpoint = partition(tag_list, distribution_list, first, last)

        quickSortHelper(tag_list, distribution_list, first, splitpoint - 1)
        quickSortHelper(tag_list, distribution_list, splitpoint + 1, last)
#*********************************************************#


#*********************************************************#
# quickSort function for tag_list and distribution_list
def quickSort(tag_list, distribution_list):
    print(len(tag_list))
    print(len(distribution_list))
    if len(tag_list) != len(distribution_list):
        print("quickSort ERROR: tag_list and distribution_list are not the same length!\n")
        return
    quickSortHelper(tag_list, distribution_list, 0, len(tag_list)-1)
#*********************************************************#


#*********************************************************#
# binarySearch function to search sorted tag_list
# returns an index of the found tag or -1 for failure to find the tag
def binarySearch(tag_list, tag):
    first = 0
    last = len(tag_list)-1

    while first <= last:
        midpoint = (first + last)//2
        if tag_list[midpoint] == tag:
            return midpoint
        else:
            if tag < tag_list[midpoint]:
                last = midpoint - 1
            else:
                first = midpoint + 1
    # failure to find tag in tag_list
    return -1
#*********************************************************#
#*****************************************************************************#



#*****************************************************************************#
# Process command line arguments
usage = "Usage: tagseek [OPTION]...\n\n"\
        "  Input/Output:\n"\
        "    -o, --out-tagpos     Output tab-deliminated file containing alignment and\n"\
        "                         tag taxa info. Default is stdout.\n"\
        "    -s, --in-sam         Input TASSEL sam file.\n"\
        "    -t, --in-tagtaxa     Input TASSEL tag taxa distribution file.\n\n"\
        "  Miscellaneous:\n"\
        "    -h, --help           Print this help message.\n"

arg = 1
state = 0
while arg < len(sys.argv):
    if state == 0:
        if sys.argv[arg] == "-o" or sys.argv[arg] == "--out-tagpos":
            state = 1
            arg += 1
        elif sys.argv[arg] == "-s" or sys.argv[arg] == "--in-sam":
            state = 2
            arg += 1
        elif sys.argv[arg] == "-t" or sys.argv[arg] == "--in-tagtaxa":
            state = 3
            arg += 1
        elif sys.argv[arg] == "-h" or sys.argv[arg] == "--help":
            print(usage)
            quit(0)
        else:
            print("Malformed arguments.\n")
            print(usage)
            quit(1)

    # -o, --out-tagpos
    elif state == 1:
        out_tagpos = sys.argv[arg]
        state = 0
        arg += 1
    # -s, --in-sam
    elif state == 2:
        in_sam = sys.argv[arg]
        state = 0
        arg += 1
    # -t, --in-tagtaxa
    elif state == 3:
        in_tagtaxadist = sys.argv[arg]
        state = 0
        arg += 1
    else:
        print("Unknown error. Exiting.\n")
        quit(1)

if state != 0:
    print("Malformed arguments.\n")
    print(usage)
    quit(1)
#*****************************************************************************#



#*****************************************************************************#
# Perform sanity checks and make sure everything is OK.

# Make sure in_sam file is specified and exists.
if in_sam == None:
    print("No input SAM file specified. Exiting.\n")
    quit(1)
if not os.path.isfile(in_sam):
    print("The file %s does not exist. Exiting.\n" % (in_sam))
    quit(1)

# Make sure tag taxa file is specified and exists
if in_tagtaxadist == None:
    print("No input TASSEL tag taxa distribution file specified. Exiting.\n")
    quit(1)
if not os.path.isfile(in_tagtaxadist):
    print("The file %s does not exist. Exiting.\n" % (in_tagtaxadist))
    quit(1)

# Make sure out_tagpos is OK
if out_tagpos == None:
    print("The output file is not specified. Exiting.\n")
    quit()
#*****************************************************************************#



#*****************************************************************************#
# Load tag taxa distribution file into memory
# FIXME: slow to load into memory because of constant appending.
with open(in_tagtaxadist, "r") as in_tagtaxadist_raw:
    linenum = 1
    for line in in_tagtaxadist_raw:
        #debug statement
        #print("Processing line: %i" % (linenum))
        if linenum == 1:
            # strip \n, split string by \t
            line_arr = line.rstrip('\n').split('\t')

            # remove the first element (Always the string: "Tag")
            line_arr.pop(0)

            # copy our list to the taxa list
            taxa = list(line_arr)

        else:
            # strip \n, split string by \t
            line_arr = line.rstrip('\n').split('\t')

            # append the tag sequences to the tags list
            tags.append(str(line_arr[0]))
            #debug statement
            #print(tags)

            # tag distribution array: uses unsigned chars to store counts; maximum of 255 counts per tag taxa
            tmp_tag_distribution = array(typecode)
            #debug statement
            #print(tmp_tag_distribution)

            i = 1
            while i < len(line_arr):
                # convert strings to numbers and add to list
                tmp_tag_distribution.append(int(line_arr[i]))
                #debug statement
                #print(tmp_tag_distribution)
                i += 1

            distributions.append(copy.copy(tmp_tag_distribution))
        linenum += 1
#*****************************************************************************#



#*****************************************************************************#
# Sort the tag and corresponding distribution lists using the tag as a key.
quickSort(tags, distributions)
#*****************************************************************************#



#*****************************************************************************#
# Read the SAM file and print to the output file.

#*********************************************************#
# Open/create the output file.
if out_tagpos != None:
    out_tagpos_raw = open(out_tagpos, "w+")
#*********************************************************#


#*********************************************************#
# Open and read the input SAM file
with open(in_sam, "r") as in_sam_raw:
    # write the header for the tagpos output file
    out_tagpos_raw.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" %
                         ( "chromosome", "start", "end", "tagSeq", "score",
                           "strand", "CIGAR", "templateLength", "seq", "PhredQualScore"))
    for genotype in taxa:
        out_tagpos_raw.write("\t%s" % (genotype))
    out_tagpos_raw.write("\n")

    for line in in_sam_raw:
        if line[0] == '@':
            continue
        columns = line.rstrip('\n').split('\t')

        # collect data from the line
        chromosome = columns[2] # 3rd column
        start = str(int(columns[3]) - 1) # 4th column - 1
        end = str(int(columns[3]) - 1 + len(columns[9])) # start + alignment seq length
        tagSeq = columns[0][7:] # 1st column, slicing off first 7 characters ("tagSeq=")
        score = columns[4] # 5th column
        strand = "+"
        if (len(columns[1]) & 0x10) != 0: # 2nd column
            strand = "-"
        cigar = columns[5] # 6th column
        tlen = columns[8] # 9th column
        seq = columns[9] # 10th column
        pqual = columns[10] # 11th column

        # write the data line
        out_tagpos_raw.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" %
                             (chromosome, start, end, tagSeq, score, strand, cigar, tlen, seq, pqual))
        index = binarySearch(tags, tagSeq)
        if index > 0:
            for count in distributions[index]:
                out_tagpos_raw.write("\t%i" % (count))
        out_tagpos_raw.write("\n")
#*********************************************************#


#*********************************************************#
# Close output file
out_tagpos_raw.close()
#*********************************************************#
#*****************************************************************************#
