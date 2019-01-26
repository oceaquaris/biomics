#!/usr/bin/env python2

import sys
import re
import os.path

samsplit_version = "v0.1"

# Variables needed for handling 'sam' files.
sam_default_regexp = '(.*?)\t(\d*?)\t(.*?)\t(\d*?)\t(\d*?)\t(.*?)\t(.*?)\t(\d*?)\t(.*?)\t(.*?)\t(.*?)\t(.*)'
QNAME   = 0     # String
FLAG    = 1     # Int
RNAME   = 2     # String
POS     = 3     # Int
MAPQ    = 4     # Int
CIGAR   = 5     # String
RNEXT   = 6     # String
PNEXT   = 7     # Int
TLEN    = 8     # Int
SEQ     = 9     # String
QUAL    = 10    # String
OTHER   = 11    # String

sam_regexp = None
paired_data = False
sam_filename = None
MIN_MAP_QUAL = 1

usage = "Usage: fastqsplit.py [OPTION]... FILE\n"\
        "  Input/Output:\n"\
        "    -E, --extended-regexp PAT  Extended regular expression for searching sam entry.\n"\
        "           ***Under development. Do not use.\n"\
        "    -p, --paired               Indicate that sam file has paired data.\n\n"\
        "  Miscellaneous:\n"\
        "    -h, --help                 Display this help message.\n"\
        "    -v, --version              Print the version of this script.\n"

arg = 1
state = 0
while arg < len(sys.argv):
    if state == 0:
        if sys.argv[arg] == "-E" or sys.argv[arg] == "--extended-regexp":
            state = 1
            arg += 1
        elif sys.argv[arg] == "-p" or sys.argv[arg] == "--paired":
            paired_data = True
            arg += 1
        elif sys.argv[arg] == "-h" or sys.argv[arg] == "--help":
            print(usage)
            quit(0)
        elif sys.argv[arg] == "-v" or sys.argv[arg] == "--version":
            print("Version information:\n    samsplit %s" % samsplit_version)
            quit(0)
        elif os.path.isfile(sys.argv[arg]):
            sam_filename = sys.argv[arg]
            arg += 1
        else:
            if not os.path.isfile(sys.argv[arg]):
                print("%s is not a valid file path." % sys.argv[arg])
            else:
                print("Malformed arguments.\n")
            print(usage)
            quit(1)
    elif state == 1:
        sam_regexp = sys.argv[arg]
        state = 0
        arg += 1
    else:
        print("Malformed arguments.\n")
        print(usage)
        quit(1)

# open input file
sam_file = open(sam_filename, "r")

# create new files
low_mapq_file = open("low_mapq.sam", "w+")
diff_rname_file = open("diff_rname.sam", "w+")
rname_files = [[], []]

state = 0
lines = []
linefinds = []
rname_index = -1
for line in sam_file:
    if line[0] == '@':
        continue

    if state == 0:
        lines.append(line)
        # findall returns a list with a tuple in it; get tuple and convert to list.
        linefinds.append(list(re.findall(sam_default_regexp, line)[0]))
        state += 1
    elif state == 1:
        # findall returns a list with a tuple in it; get tuple and convert to list.
        linefind = list(re.findall(sam_default_regexp, line)[0])
        #print(linefind)
        #print(linefind)
        if linefinds[len(lines) - 1][0] == linefind[0]:
            lines.append(line)
            linefinds.append(linefind[0]) #findall returns a list containing a tuple.
        else:
            #determine which file to write to
            index = len(linefinds) - 1
            mapped = True
            same_chr = True
            while index >= 0:
                #print(linefinds)
                #print("linefinds[%i][%i]" % (index, MAPQ))
                #print(linefinds[index])
                #print(type(linefinds[index]))
                #print(linefinds[index][0])
                #print(type(linefinds[index][0]))
                mapped = mapped and (not int(linefinds[index][MAPQ]) < MIN_MAP_QUAL)
                same_chr = same_chr and (linefinds[0][RNAME] == linefinds[index][RNAME])
                index -= 1

            print(lines)
            #write found articles to files
            if mapped:
                if same_chr:
                    for index in xrange(len(rname_files[0])):
                        if rname_files[0][index] == linefinds[0][RNAME]:
                            rname_index = index
                            break
                    if rname_index == -1:
                        rname_files[0].append(linefinds[0][RNAME])
                        rname_files[1].append(open(linefinds[0][RNAME] + ".sam", "w+"))
                        rname_index = len(fastq_groups[0]) - 1
                    for index in xrange(len(lines)):
                        rname_files[1][rname_index].write(lines[index])
                else:
                    for index in xrange(len(lines)):
                        diff_rname_file.write(line[0])
            else:
                for index in xrange(len(lines)):
                    low_mapq_file.write(line[0])

            #clear the arrays
            del lines[:]
            del linefinds[:]

            # put new entries into array
            lines.append(line)
            linefinds.append(linefind)
            state = 1
