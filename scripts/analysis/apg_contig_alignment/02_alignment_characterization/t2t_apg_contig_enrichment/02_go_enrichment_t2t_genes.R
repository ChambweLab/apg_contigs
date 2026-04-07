#!/usr/bin/env Rscript

# --------------------------------------------------
# Script: 02_go_enrichment_t2t_genes.R
# Description:
#   Perform Gene Ontology over-representation analysis on
#   T2T-CHM13 genes overlapped by APG contigs.
#
# Inputs:
#   1. Gene overlap table for APG contigs mapped to T2T-CHM13
#   2. T2T-CHM13 gene annotation table used to define the gene universe
#
# Output:
#   GO enrichment result table filtered at FDR <= 0.05
#
# Notes:
#   - Input and output paths below are placeholders and should be updated
#     to match the local project structure before running.
#   - Gene symbols are used as input to enrichGO().
# --------------------------------------------------

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tibble)
  library(clusterProfiler)
  library(org.Hs.eg.db)
})

# --------------------------------------------------
# File paths
# --------------------------------------------------

input_overlap_genes <- "/path/to/contigs_genes_overlap_t2t_GeneNames.csv"
input_all_t2t_genes <- "/path/to/NCBI_RefSeq_Gene_Annotations_T2T.csv"
output_enrichment_csv <- "/path/to/apg_contig_t2t_np_geneslist_OVA.csv"

# --------------------------------------------------
# Load input data
# --------------------------------------------------

# Table containing APG contig overlaps with T2T-CHM13 genes
apg_contig_t2t_genes <- read_csv(input_overlap_genes, show_col_types = FALSE)

# Table containing the full T2T-CHM13 gene annotation set
all_t2t_genes <- read_csv(input_all_t2t_genes, show_col_types = FALSE)

# --------------------------------------------------
# Define background universe and input gene list
# --------------------------------------------------

# Universe of unique annotated T2T genes
univ_t2t <- all_t2t_genes %>%
  pull(geneName2) %>%
  unique() %>%
  na.omit()

# Genes with at least one APG contig overlapping them

apg_contig_t2t_np_geneslist <- apg_contig_t2t_genes %>%
  filter(V11 != "No") %>%
  filter(!is.na(geneName2)) %>%
  distinct(geneName2) %>%
  pull(geneName2)

message("Number of unique APG-overlapping T2T genes: ", length(apg_contig_t2t_np_geneslist))
message("Number of genes in T2T universe: ", length(univ_t2t))

# --------------------------------------------------
# Run GO over-representation analysis
# --------------------------------------------------

go_enrichment <- enrichGO(
  gene = apg_contig_t2t_np_geneslist,
  OrgDb = org.Hs.eg.db,
  keyType = "SYMBOL",
  universe = univ_t2t,
  ont = "all"
)

# Keep significant terms and relevant summary columns
go_results <- go_enrichment@result %>%
  as_tibble() %>%
  filter(p.adjust <= 0.05) %>%
  select(
    ID,
    ONTOLOGY,
    Description,
    GeneRatio,
    FoldEnrichment,
    pvalue,
    p.adjust,
    geneID
  )

# --------------------------------------------------
# Export results
# --------------------------------------------------

write_csv(go_results, output_enrichment_csv)

message("GO enrichment results written to: ", output_enrichment_csv)
