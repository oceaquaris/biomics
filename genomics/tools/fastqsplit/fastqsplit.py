#!/usr/bin/env python2

import sys
import re
import os.path

fastqsplit_version = "v0.1"
seq_id_regexp = None
unpaired_reads_filepath = None
unpaired_mode = False
paired_reads1_filepath = None
paired_reads2_filepath = None
paired_mode = False

usage = "Usage: fastqsplit.py [OPTION]...\n"\
        "  Input/Output:\n"\
        "    -E, --extended-regexp PAT\n"\
        "    -r, --unpaired-reads\n"\
        "    -1, --paired-reads1\n"\
        "    -2, --paired-reads2\n\n"\
        "  Miscellaneous:\n"\
        "    -h, --help\n"\
        "    -v, --version\n"

arg = 1
state = 0
while arg < len(sys.argv):
    if state == 0:
        if sys.argv[arg] == "-E" or sys.argv[arg] == "--extended-regexp":
            state = 1
            arg += 1
        elif sys.argv[arg] == "-r" or sys.argv[arg] == "--unpaired-reads":
            state = 2
            arg += 1
        elif sys.argv[arg] == "-1" or sys.argv[arg] == "--paired-reads1":
            state = 3
            arg += 1
        elif sys.argv[arg] == "-2" or sys.argv[arg] == "--paired-reads2":
            state = 4
            arg += 1
        elif sys.argv[arg] == "-h" or sys.argv[arg] == "--help":
            print(usage)
            quit(0)
        elif sys.argv[arg] == "-v" or sys.argv[arg] == "--version":
            print("Version information:\n    fastqsplit %s" % fastqsplit_version)
            quit(0)
        else:
            print("Malformed arguments.\n")
            print(usage)
            quit(1)
    elif state == 1:
        seq_id_regexp = sys.argv[arg]
        state = 0
        arg += 1
    elif state == 2:
        unpaired_reads_filepath = sys.argv[arg]
        state = 0
        arg += 1
    elif state == 3:
        paired_reads1_filepath = sys.argv[arg]
        state = 0
        arg += 1
    elif state == 4:
        paired_reads2_filepath = sys.argv[arg]
        state = 0
        arg += 1
    else:
        print("Malformed arguments.\n")
        print(usage)
        quit(1)

# sanity checks
if unpaired_reads_filepath and (paired_reads1_filepath or paired_reads2_filepath):
    print("Too many read data arguments. -r and -1/-2 arguments are mutually exclusive.\n")
    print(usage)
    quit(1)
if paired_reads1_filepath == None or paired_reads2_filepath == None:
    print("Too few paired end read arguments.\n")
    print(usage)
    quit(1)
if seq_id_regexp == None:
    print("Regular expression needed.\n")
    print(usage)
    quit(1)
if not os.path.isfile(unpaired_reads_filepath):
    print("The file %s does not exist. Exiting.\n" % unpaired_reads_filepath)
    quit(1)
if not os.path.isfile(paired_reads1_filepath):
    print("The file %s does not exist. Exiting.\n" % paired_reads1_filepath)
    quit(1)
if not os.path.isfile(paired_reads2_filepath):
    print("The file %s does not exist. Exiting.\n" % paired_reads2_filepath)
    quit(1)

pattern = re.compile(seq_id_regexp) if seq_id_regexp != None else None
if unpaired_reads_filepath:
    fastq_groups = [None] * 2
    fastq_groups[0] = []
    fastq_groups[1] = []
    unpaired_reads_file = open(unpaired_reads_filepath, "r")
    quartet = 0
    group_index = -1
    for line in unpaired_reads_file:
        quartet += 1
        if quartet == 1
            match = pattern.search(line)
            if match:
                for index in xrange(pattern.group):
                    key = key + match.group(index + 1) + "."
                    key = ""
                for index in xrange(len(fastq_groups[0])):
                    if fastq[index] == tmpstr:
                        group_index = index
                if group_index == -1:
                    fastq_groups[0].append(key)
                    newfn = key + "fastq"
                    fastq_groups[1].append(open(newfn, "w+"))
                    group_index = len(fastq_groups[0]) - 1
        fastq_groups[1][group_index].write(line)
        if quartet == 4:
            quartet = 0
if paired_reads1_filepath and paired_reads2_filepath:
    fastq_groups = [None] * 3
    fastq_groups[0] = []
    fastq_groups[1] = []
    fastq_groups[2] = []
    paired_reads1_file = open(paired_reads1_filepath, "r")
    paired_reads2_file = open(paired_reads2_filepath, "r")
    quartet = 0
    group_index = -1
    for line in paired_reads1_file:
        quartet += 1
        if quartet == 1
            match = pattern.search(line)
            if match:
                for index in xrange(pattern.group):
                    key = key + match.group(index + 1) + "."
                    key = ""
                for index in xrange(len(fastq_groups[0])):
                    if fastq[index] == tmpstr:
                        group_index = index
                if group_index == -1:
                    fastq_groups[0].append(key)
                    fastq_groups[1].append(open(key + "R1." + "fastq", "w+"))
                    fastq_groups[2].append(open(key + "R2." + "fastq", "w+"))
                    group_index = len(fastq_groups[0]) - 1
        fastq_groups[1][group_index].write(line)
        fastq_groups[2][group_index].write(paired_reads2_file.next())
        if quartet == 4:
            quartet = 0
