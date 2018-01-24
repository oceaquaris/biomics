/**
 * @file TASSEL5hmp2numhmp.c
 * @version 0.1
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int file_exists(const char *filename);
static int cpyline(FILE *src, FILE *dest, int *exitstate);
static int cpycol(FILE *src, FILE *dest, int *exitstate);
static int parsealleles(FILE *src, FILE *dest, int *parsestate, int *exitstate);
static int parseSNP(FILE *src, FILE *dest, int allelestate, int *exitstate);
static int parseline(FILE *src, FILE *dest, int *exitstate);


static const char usage[] =
"Usage: TASSEL5hmp2numhmp [INFILE] [OUTFILE]\n"\
               "    Where:\n"\
               "        INFILE the name of a TASSEL 5 HapMap file (tab-delimited text).\n"\
               "        OUTFILE is the name of the converted numerical HapMap file.\n";

int main(int argc, char *argv[]) {
    if(argc != 3) {
        printf(usage);
        return 0;
    }
    
    if(!file_exists(argv[1])) {
        printf("The INFILE \"%s\" does not exist.\n", argv[1]);
        printf(usage);
        return 1;
    }
    
    FILE *infile, *outfile;
    infile = fopen(argv[1], "r");
    outfile = fopen(argv[2], "w");
    
    int tmpexitstate;
    cpyline(infile, outfile, &tmpexitstate);
    if(tmpexitstate == 0) {
        fclose(infile);
        fclose(outfile);
        fprintf(stderr, "Malformed column header row. Exiting.\n");
        return 1;
    }
    
    while(tmpexitstate != 0) {
        parseline(infile, outfile, &tmpexitstate);
    }
    
    fclose(infile);
    fclose(outfile);
    return 0;
}


static int file_exists(const char *filename) {
    FILE *file;
    file = fopen(filename, "r");
    if(file) {
        fclose(file);
        return 1;
    }
    return 0;
}


static int cpyline(FILE *src, FILE *dest, int *exitstate) {
    int copied = 0;
    int c;
    
    while((c = fgetc(src) != EOF)) {
        fputc(c, dest);
        copied++;
        if(c == '\n' || c == '\r\n') {
            *exitstate = c;
            return copied;
        }
    }
    *exitstate = 0;
    return copied;
}


static int cpycol(FILE *src, FILE *dest, int *exitstate) {
    int copied = 0;
    int c;
    
    while((c = fgetc(src) != EOF)) {
        fputc(c, dest);
        copied++;
        if(c == '\t' || c == '\n' || c == '\r\n') {
            *exitstate = c;
            return copied;
        }
    }
    *exitstate = 0;
    return copied;
}


enum nucleotide {
    NUCLEOTIDE_A = 1,
    NUCLEOTIDE_C = 2,
    NUCLEOTIDE_G = 4,
    NUCLEOTIDE_T = 8,
    NUCLEOTIDE_ERROR = 16
};


static int parsealleles(FILE *src, FILE *dest, int *parsestate, int *exitstate) {
    int copied = 0;
    int c;
    int state;
    
    //set parsestate to zero
    *parsestate = 0;
    
    for(state = 1; state < 5; state++) {
        c = fgetc(src);
        if(c == EOF) {
            *exitstate = 0;
            return copied;
        }
        switch(state) {
            case 1:
            case 3:
                switch(c) {
                    case 'A':
                    case 'a':
                        *parsestate |= NUCLEOTIDE_A;
                        break;
                    case 'C':
                    case 'c':
                        *parsestate |= NUCLEOTIDE_C;
                        break;
                    case 'G':
                    case 'g':
                        *parsestate |= NUCLEOTIDE_G;
                        break;
                    case 'T':
                    case 't':
                        *parsestate |= NUCLEOTIDE_T;
                        break;
                    default:
                        break;
                }
                copied += fputc(c, dest);
                break;
            case 2:
                if(c != '/') {
                    *exitstate = 0;
                    return copied;
                }
                copied += fputc(c, dest);
                break;
            case 4:
                if(c == '\t' || c == '\n' || c == '\r\n') {
                    *exitstate = c;
                    copied += fputc(c, dest);
                    break;
                }
            default:
                *exitstate = 0;
                return copied;
        }
    }
    return copied;
}


static int parseSNP(FILE *src, FILE *dest, int allelestate, int *exitstate) {
    int copied = 0;
    int c;
    int state;
    int snp = 0;
    
    for(state = 1; state < 4; state++) {
        c = fgetc(src);
        if(c == EOF) {
            *exitstate = 0;
            return copied;
        }
        switch(state) {
            case 1:
            case 2:
                switch(allelestate) {
                    case NUCLEOTIDE_A|NUCLEOTIDE_C:
                        switch(c) {
                            case 'A':
                            case 'a':
                                snp |= NUCLEOTIDE_A;
                                break;
                            case 'C':
                            case 'c':
                                snp |= NUCLEOTIDE_C;
                                break;
                            default:
                                snp |= NUCLEOTIDE_ERROR;
                                break;
                        }
                    case NUCLEOTIDE_A|NUCLEOTIDE_G:
                        switch(c) {
                            case 'A':
                            case 'a':
                                snp |= NUCLEOTIDE_A;
                                break;
                            case 'G':
                            case 'g':
                                snp |= NUCLEOTIDE_G;
                                break;
                            default:
                                snp |= NUCLEOTIDE_ERROR;
                                break;
                        }
                    case NUCLEOTIDE_A|NUCLEOTIDE_T:
                        switch(c) {
                            case 'A':
                            case 'a':
                                snp |= NUCLEOTIDE_A;
                                break;
                            case 'T':
                            case 't':
                                snp |= NUCLEOTIDE_T;
                                break;
                            default:
                                snp |= NUCLEOTIDE_ERROR;
                                break;
                        }
                    case NUCLEOTIDE_C|NUCLEOTIDE_G:
                        switch(c) {
                            case 'C':
                            case 'c':
                                snp |= NUCLEOTIDE_C;
                                break;
                            case 'G':
                            case 'g':
                                snp |= NUCLEOTIDE_G;
                                break;
                            default:
                                snp |= NUCLEOTIDE_ERROR;
                                break;
                        }
                    case NUCLEOTIDE_C|NUCLEOTIDE_T:
                        switch(c) {
                            case 'C':
                            case 'c':
                                snp |= NUCLEOTIDE_C;
                                break;
                            case 'T':
                            case 't':
                                snp |= NUCLEOTIDE_T;
                                break;
                            default:
                                snp |= NUCLEOTIDE_ERROR;
                                break;
                        }
                    case NUCLEOTIDE_G|NUCLEOTIDE_T:
                        switch(c) {
                            case 'G':
                            case 'g':
                                snp |= NUCLEOTIDE_G;
                                break;
                            case 'T':
                            case 't':
                                snp |= NUCLEOTIDE_T;
                                break;
                            default:
                                snp |= NUCLEOTIDE_ERROR;
                                break;
                        }
                    default:
                        *exitstate = 0;
                        return copied;
                }
                break;
            case 3:
                if(c == '\t' || c == '\n' || c == '\r\n') {
                    *exitstate = c;
                    break;
                }
            default:
                *exitstate = 0;
                return copied;
        }
    }

    switch(allelestate) {
        case NUCLEOTIDE_A|NUCLEOTIDE_C:
            switch(snp) {
                case NUCLEOTIDE_A:
                    copied += fputs("-1", dest);
                    break;
                case NUCLEOTIDE_A|NUCLEOTIDE_C:
                    copied += fputs("0", dest);
                    break;
                case NUCLEOTIDE_C:
                    copied += fputs("1", dest);
                    break;
                default:
                    copied += fputs("na", dest);
                    break;
            }
        case NUCLEOTIDE_A|NUCLEOTIDE_G:
            switch(snp) {
                case NUCLEOTIDE_A:
                    copied += fputs("-1", dest);
                    break;
                case NUCLEOTIDE_A|NUCLEOTIDE_G:
                    copied += fputs("0", dest);
                    break;
                case NUCLEOTIDE_G:
                    copied += fputs("1", dest);
                    break;
                default:
                    copied += fputs("na", dest);
                    break;
            }
        case NUCLEOTIDE_A|NUCLEOTIDE_T:
            switch(snp) {
                case NUCLEOTIDE_A:
                    copied += fputs("-1", dest);
                    break;
                case NUCLEOTIDE_A|NUCLEOTIDE_T:
                    copied += fputs("0", dest);
                    break;
                case NUCLEOTIDE_T:
                    copied += fputs("1", dest);
                    break;
                default:
                    copied += fputs("na", dest);
                    break;
            }
        case NUCLEOTIDE_C|NUCLEOTIDE_G:
            switch(snp) {
                case NUCLEOTIDE_C:
                    copied += fputs("-1", dest);
                    break;
                case NUCLEOTIDE_C|NUCLEOTIDE_G:
                    copied += fputs("0", dest);
                    break;
                case NUCLEOTIDE_G:
                    copied += fputs("1", dest);
                    break;
                default:
                    copied += fputs("na", dest);
                    break;
            }
        case NUCLEOTIDE_C|NUCLEOTIDE_T:
            switch(snp) {
                case NUCLEOTIDE_C:
                    copied += fputs("-1", dest);
                    break;
                case NUCLEOTIDE_C|NUCLEOTIDE_T:
                    copied += fputs("0", dest);
                    break;
                case NUCLEOTIDE_T:
                    copied += fputs("1", dest);
                    break;
                default:
                    copied += fputs("na", dest);
                    break;
            }
        case NUCLEOTIDE_G|NUCLEOTIDE_T:
            switch(snp) {
                case NUCLEOTIDE_G:
                    copied += fputs("-1", dest);
                    break;
                case NUCLEOTIDE_G|NUCLEOTIDE_T:
                    copied += fputs("0", dest);
                    break;
                case NUCLEOTIDE_T:
                    copied += fputs("1", dest);
                    break;
                default:
                    copied += fputs("na", dest);
                    break;
            }
        default:
            copied += fputs("na", dest);
            break;
    }

    switch(*exitstate) {
        case '\t':
        case '\n':
        case '\r\n':
            copied += fputc(*exitstate, dest);
            break;
        default:
            *exitstate = 0;
            return copied;
    }
    
    return copied;
}


static int parseline(FILE *src, FILE *dest, int *exitstate) {
    int copied = 0;
    int tmpexitstate;
    int allelestate;
    int i;
    
    copied += cpycol(src, dest, &tmpexitstate);
    if(tmpexitstate == 0) {
        *exitstate = 0;
        return copied;
    }
    
    copied += parsealleles(src, dest, &allelestate, &tmpexitstate);
    if(tmpexitstate == 0) {
        *exitstate = 0;
        return copied;
    }
    
    for(i = 0; i < 9; i++) {
        copied += cpycol(src, dest, &tmpexitstate);
        if(tmpexitstate == 0) {
            *exitstate = 0;
            return copied;
        }
    }
    
    do {
        copied += parseSNP(src, dest, allelestate, &tmpexitstate);
        if(tmpexitstate == 0) {
            *exitstate = 0;
            return copied;
        }
    } while(tmpexitstate != '\n' || tmpexitstate != '\r\n');
    
    *exitstate = tmpexitstate;
    return copied;
}