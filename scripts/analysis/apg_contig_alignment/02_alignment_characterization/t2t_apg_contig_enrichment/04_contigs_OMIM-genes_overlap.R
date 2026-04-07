# Load libraries
library(readr)
library(stringr)

# Load data
## Load file with apg-contigs/gene overlap (colnames should be: "chr","contig_start","contig_end","contig_id","GeneName")
contig_genes <- read_csv("contigs_genes_overlap_t2t_GeneNames.csv")

## Load genes linked to phenotype from OMIM database
omim <- read_delim("genemap2.txt", 
                   delim = "\t", escape_double = FALSE, 
                   trim_ws = TRUE, skip = 3)

colnames(omim)[9] <- "GeneName"

# Identify genes overlapping apg-contigs that are also reported in the OMIM database
omim_genes <- merge(contig_genes, omim[,-14],by="GeneName")

# Keep only the genes with reported OMIM phenotypes
omim_genes_pheno <- omim_genes[-which(is.na(omim_genes$Phenotypes)),] 

# Save results
write.csv(omim_genes_pheno, "omim-genes_contigs_overlap.csv",
          row.names=FALSE)