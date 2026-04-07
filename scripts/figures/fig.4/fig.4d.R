###################################################################
### Create binarized heatmap for differentially covered apg-contigs ###
###################################################################

# Load libraries
library(ggplot2)
library(readr)
library(tidyverse)
library(dplyr)
library(readxl)
library(ComplexHeatmap)  
library(circlize)

#=======================================================================================  
# 0. Load and preprocess differential contig coverage results & various annotation files
# ====================================================================================== 

# Load diffential contigs coverage results for the two cohorts (generated using "HPRCcontigs_diff_coverage_by_population.Rmd" script)
res1 <- read.csv("sig_diff_1KG_t100.csv") 
res2 <- read.csv("sig_diff_TCGA_t100.csv") 

# Create "cohort" column and combine data
res1$Cohort <- "1000 Genomes"
res2$Cohort <- "TCGA BRCA"
combined <- rbind(res1, res2)

# Load GRCh38 placement information for contigs
placement <- read_excel("end_placement.xlsx")
colnames(placement) <- placement[1,]
placement <- placement[-1,]

colnames(placement)[3] <- "contig"

# Load HPRC assembly population-level DNA mapping
pop <- read_excel("C:/Users/kfounta/OneDrive - Northwell Health/Founta-Chambwe-Shared-Folder/Projects/MacMillan/results/apg_contigs_paper/rnaseq_alignment/HPRCcontigs_alignment/pop_alignment.xlsx")
colnames(pop) <- pop[1,]
pop <- pop[-1,]
colnames(pop)[1] <- "contig_name"

# Condense all information into a combined df
merged1 <- unique(merge(combined, placement[,c("contig_name","Placed/Unplaced","contig")], by = "contig"))
merged2 <- merge(merged1, pop, by="contig_name")

merged2 <- merged2[order(merged2$Cohort, decreasing = T),]

#============================================================  
# 1. Reformat dataframe to be used to plot the binarized heatmap
# ============================================================  

heatmap_df <- merged2 %>%  
  mutate(  
    # Enrichment  
    Enriched_in_AFR = as.integer(color_group == "Enriched in AFR"),  
    Enriched_in_EUR = as.integer(color_group == "Enriched in EUR"),  
    
    # Cohort  
    TCGA_BRCA = as.integer(Cohort == "TCGA BRCA"),  
    `1000_Genomes` = as.integer(Cohort == "1000 Genomes"),  
    
    # Maps to population  
    Maps_to_AFR = as.integer(AFR == 1),  
    Maps_to_EUR = as.integer(EUR == 1),  
    
    # Exclusive mapping (only that population = 1, all others = 0)  
    Exclusive_AFR = as.integer(AFR == 1 & EUR == 0 & AMR == 0 & EAS == 0 & SAS == 0),  
    Exclusive_EUR = as.integer(EUR == 1 & AFR == 0 & AMR == 0 & EAS == 0 & SAS == 0),  
    
    # Placement type  
    Unplaced = as.integer(`Placed/Unplaced` == "Unplaced"),  
    One_End_Placed = as.integer(`Placed/Unplaced` == "One End Placed"),  
    Two_End_Placed = as.integer(`Placed/Unplaced` == "Two End Placed")  
  ) %>%  
  select(contig,  
         Enriched_in_AFR, Enriched_in_EUR,  
         TCGA_BRCA, `1000_Genomes`,  
         Maps_to_AFR, Maps_to_EUR,  
         Exclusive_AFR, Exclusive_EUR,  
         Unplaced, One_End_Placed, Two_End_Placed)

# Convert to matrix  
heatmap_df <- as.data.frame(unique(heatmap_df))
rownames(heatmap_df) <- NULL

heatmap_df2 <- heatmap_df %>%  
  select(-TCGA_BRCA, -`1000_Genomes`)

rownames(heatmap_df2) <- NULL  

# ============================================================  
# 2. Create Cohort row annotation  
# ============================================================

# Get cohort info per contig from original df  
cohort_info <- merged2 %>%    
  select(contig, Cohort) %>%    
  distinct()

# Get placement type info per contig from original df  
placement_info <- merged2 %>%  
  select(contig, "Placed/Unplaced") %>%   # adjust column name to match your data  
  distinct()

# Match to matrix row order    
cohort_vec <- cohort_info$Cohort

mat <- heatmap_df2  
row.names(mat) <- mat$contig  
mat <- mat[, -1]

mat <- mat[cohort_info$contig, ]  
all.equal(row.names(mat), cohort_info$contig)

# Create placement vector matched to row order  
placement_vec <- placement_info$`Placed/Unplaced`[match(row.names(mat), placement_info$contig)]  

# Define row annotations for heatmap  
row_ha <- rowAnnotation(  
  Cohort = cohort_vec,  
  `Placement Type` = placement_vec,  
  col = list(  
    Cohort = c("TCGA BRCA" = "#838B83",   
               "1000 Genomes" = "#8B1C62"),  
    `Placement Type` = c("Unplaced"  = "#CD3333",  
                         "One End Placed"   = "#FF7F00",  
                         "Two End Placed"   = "#4DAF4A")  
  ),  
  annotation_name_gp = gpar(fontsize = 10, fontface = "bold"),  
  annotation_legend_param = list(  
    Cohort = list(title = "Cohort",   
                  title_gp = gpar(fontsize = 10, fontface = "bold")),  
    `Placement Type` = list(title = "Placement Type",  
                            title_gp = gpar(fontsize = 10, fontface = "bold"))  
  )  
)  

# ============================================================  
# 3. Update column groupings (without Cohort columns)  
# ============================================================

# Remove placement type columns from the matrix (placement type will be added as row.annotation) 
rm_cols <- c("Unplaced", "One_End_Placed", "Two_End_Placed","Exclusive_AFR", "Exclusive_EUR")  # adjust names to match  
mat <- mat[, !(colnames(mat) %in% rm_cols)]

# Update column groupings (without Placement Type)  
column_groups <- factor(  
  c("Coverage\nEnrichment", "Coverage\nEnrichment",  
    "HPRC\nMapping", "HPRC\nMapping"),  
  levels = c("Coverage\nEnrichment", "HPRC\nMapping")  
)

col_labels <- c(  
  "AFR", "EUR",  
  "AFR", "EUR"
)  

# ============================================================  
# 4. Generate final heatmap 
# ============================================================

ht <- Heatmap(  
  mat, 
  name = "Status",  
  col = colorRamp2(c(0, 1), c("#f5f5f5", "gray35")),  
  
  # Cell appearance — color only, no text  
  rect_gp = gpar(col = "white", lwd = 2),  
  show_heatmap_legend = FALSE,  
  
  # Column settings  
  column_split = column_groups,  
  column_labels = col_labels,  
  column_names_rot = 0,  
  column_names_centered = TRUE,  
  column_names_gp = gpar(fontsize = 10),  
  column_title_gp = gpar(fontsize = 10, fontface = "bold"),  
  column_gap = unit(3, "mm"),  
  
  # Row settings  
  row_names_side = "left",  
  row_names_gp = gpar(fontsize = 10),  
  cluster_rows = FALSE,  
  cluster_columns = FALSE, 
  
  # Row annotation (Cohort)  
  left_annotation = row_ha,  
  
  # Legend  
  heatmap_legend_param = list(  
    title = "Status",  
    at = c(0, 1),  
    labels = c("Absent", "Present"),  
    border = "black"  
  ),  
  
  border = TRUE 
)

# Save plot to a .pdf file
pdf("binarized_heatmap_hprc-contig_diff_cov.pdf", 
    width = 5.5, height = 5)  
draw(ht,   
     column_title = "",  
     column_title_gp = gpar(fontsize = 14, fontface = "bold"),  
     padding = unit(c(2, 2, 10, 15), "mm"))  # top, left, top-title, BOTTOM  
dev.off()
