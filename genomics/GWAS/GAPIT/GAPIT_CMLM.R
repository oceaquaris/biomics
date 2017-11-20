###############################################################################
# GAPIT - Genomic Association and Prediction Integrated Tool
# Designed by Zhiwu Zhang
# Written by Zhiwu Zhang, Alex Lipka, Feng Tian and You Tang
###############################################################################


###############################################################################
# Script variables to be customized by the user.

# MODIFY ME: Path to the R package mirror to use.
# See https://cran.r-project.org/mirrors.html for more details.
package_mirror = "https://cloud.r-project.org/"

# MODIFY ME: Path to the R working directory (the location where you want to
#   output GAPIT output to). NOTE: No trailing slash on directory.
gapit_working_directory = "/path/to/GAPIT/working/directory"

# MODIFY ME:
#   phenotypic_data: Path to GWAS phenotypic data.
#   phenotypic_head: Does this data have a header row?
phenotypic_data = "/path/to/GWAS/phenotype/data"
phenotypic_head = TRUE

# MODIFY ME:
#   genotypic_data: Path to GWAS genotypic data.
#   genotypic_head: Does this data have a header row?
genotypic_data = "/path/to/GWAS/genotype/data"
genotypic_head = FALSE
###############################################################################


# Set the working directory for R
setwd(gapit_working_directory)


###############################################################################
#Install packages (Do this section only for new installation of R)

# Install packages from bioconductor.org
source("https://www.bioconductor.org/biocLite.R") 
biocLite("multtest")
biocLite("chopsticks")

# Install packages from our package mirror.
install.packages("gplots",        repos = package_mirror)
install.packages("scatterplot3d", repos = package_mirror)
install.packages("LDheatmap",     repos = package_mirror)
install.packages("genetics",      repos = package_mirror)
install.packages("ape",           repos = package_mirror)
install.packages("EMMREML",       repos = package_mirror)
###############################################################################


###############################################################################
# Step 0: Import library and GAPIT functions (run this section each time to start R)
library(MASS) # required for ginv
library(scatterplot3d)
library(multtest)
library(gplots)
library(LDheatmap)
library(genetics)
library(ape)
library(EMMREML)
library(compiler) #this library is already installed in R library("scatterplot3d")

# The GAPIT package can be installed by:
source("http://www.zzlab.net/GAPIT/emma.txt")

# The EMMA library was developed by Kang et al. (2008).
# One line was added to the library to handle the grid search with “NA” likelihood.
# The modified library can be installed by:
source("http://www.zzlab.net/GAPIT/gapit_functions.txt")
###############################################################################



###################################################################################
## Basic Scenario of Compressed MLM by Zhang and et. al. (Nature Genetics, 2010) ##
###################################################################################

# Step 1: Set data directory and import files
Pheno <- read.table(phenotypic_data, head = phenotypic_head)
Geno  <- read.table(genotypic_data,  head = genotypic_head) # Data Format: save as file hapmap diploid

# Step 2: Run GAPIT
myGAPIT <- GAPIT(
    Y = Pheno,              # Phenotypic data
    G = Geno,               # Genotypic data
    PCA.total = 3,          # Principle component number
    PCA.View.output = FALSE # View PCA output
)
