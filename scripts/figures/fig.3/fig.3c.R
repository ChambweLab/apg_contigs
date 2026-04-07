# Load libraries
library(readr)
library(ggplot2)
library(dplyr)
library(stringr)

# Load apg-contig/GWAS hit overlap file generated in "3_contigs_GWAS-hits_overlap.R"
overlapping_intervals <- read_csv("contigs_gwas-hits_overlap_t2t.csv")

# Preprocess data by selecting columns of interest
proc <- unique(overlapping_intervals[,c("chr","contig_name", "snp","trait","gene")])
head(proc)

# Load GWAS trait category file
categories <- read_delim("gwas_catalog_trait-mappings_r2025-10-15.tsv", 
                         delim = "\t", escape_double = FALSE, 
                         trim_ws = TRUE)

categories <- as.data.frame(categories)
colnames(categories)[c(1,4)] <- c("trait","parent_term")

# Create table with number of contigs per chromosome and trait
contigs <- unique(proc[,c("chr","contig_name","trait")])
contigs2 <- unique(merge(contigs, categories[,c("trait", "parent_term")], 
                         by="trait", all.x = T))

# Generate contig counts for a combination of chromosome and trait 
counts_chr_trait <- contigs2 %>% 
  group_by(chr, trait, parent_term) %>%
  summarise(n = n(), .groups = "drop")

counts_chr_trait <- counts_chr_trait[order(counts_chr_trait$n, decreasing = T),]

# Keep unique parent terms
df_unique <- counts_chr_trait %>%
  distinct(chr,trait,n, .keep_all = TRUE)
dim(df_unique)

# Reformat chromosomes appropriately for plotting
df_unique$chr <- gsub("chr","",df_unique$chr)
df_unique$chr <- as.numeric(df_unique$chr)

# Generate  Manhattan-like plot for chromosome 6
library(ggplot2)
library(ggrepel)
library(randomcoloR)
library(ggpubr)

gwas_cols <- c("#458B00","#874bcc","#A52A2A","#d8db2b","#EE1289","#2F4F4F","#c47636",
               "#ed9ea0","#43CD80","#8B8378","#0000FF" ,"#ff0000","#66CDAA")

## Preselect chromosome 6 hits
chr6 <- df_unique[which(df_unique$chr == "6"),]
chr6$chr <- as.character(chr6$chr)
chr6$chr <- paste0("Chromosome ",chr6$chr)
chr6_2 <- chr6 # Save a copy of df to plot

## Wrap name of specific trait (it is too long and gets cut when writing the plot to a file)
chr6_2[23,2] <- str_wrap("HLA class II histocompatibility antigen, \nDQ alpha 2 chain levels (HLA.DQA2.7757.5.3)", width = 41)

p <- ggplot(chr6_2, aes(x=chr, y=n, color=parent_term,label = trait)) + 
  geom_point(position = position_jitter(width = 0.25, height = 0), size = 1.5, alpha = 0.7)+
  theme(text = element_text(size=14),axis.text=element_text(size=14),plot.title = element_text(size = 15,  face = "bold"),
        axis.text.x=element_text(color="black", hjust = 1),
        axis.text.y=element_text(color="black") ,
        panel.background = element_blank(),axis.line = element_line(colour = "black"),
        axis.ticks = element_line(color = "black"),panel.border = element_rect(colour = "black", fill=NA, size=0.2))+
  geom_label_repel(
    size = 3,
    segment.color = "gray70",
    segment.size = 0.2,
    label.size = 0.11,   # removes label border
    box.padding = 0.2,
    point.padding = 0.15,
    show.legend = TRUE,
    force=1.5
  )+
  ylab("Number of Contigs Per Trait")+
  xlab("")+
  scale_y_continuous(breaks=seq(0,15,1))+
  scale_color_manual(values = gwas_cols)+
  coord_cartesian(clip = "off")

ggpar(p, legend.title = "Trait Category", legend = "right")

## Save plot
ggsave("contigs_GWAS_manhattan_chr6_alt.jpeg", 
       width = 20, height = 20, device='jpeg', dpi=700,units = c("cm"))
