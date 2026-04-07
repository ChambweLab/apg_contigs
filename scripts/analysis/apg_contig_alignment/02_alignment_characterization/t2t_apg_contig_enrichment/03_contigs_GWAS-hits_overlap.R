library(vcfR)
library(readr)
library(rtracklayer)

# Load GWAS hits catalog
gwas <- read_delim("gwas_catalog_v1.0-associations_e114_r2025-07-21.tsv", 
                   delim = "\t", escape_double = FALSE, 
                   trim_ws = TRUE)

# Load file with T2T-CHM13 variant position for GWAS hits
vcf_data <- read.vcfR("chm13v2.0_GWASv1.0rsids_e100_r2022-03-08.vcf")

t2t_pos <- as.data.frame(vcf_data@fix)
colnames(t2t_pos)[c(1:5)] <- c("CHROM_T2T", "POS_T2T","SNPS","REF_T2T","ALT_T2T")

gwas_t2t <- merge(gwas, t2t_pos, by="SNPS")

# Load apg-contigs file with T2T-CHM13 locations
contigs <- read.table("all_apg_contigs_alignments_t2t_sorted.bed", header = FALSE, sep = "\t")

# Keep only variables of interest from GWAS annotation dataframe
gwas_t2t <- gwas_t2t[,c(35,36,1,9,10,16,6)]
gwas_t2t$start <- gwas_t2t$POS_T2T-1
gwas_t2t$end <- gwas_t2t$POS_T2T

# Trasnform  GWAS annotation df to bed file
gwas_t2t_bed <- GRanges(gwas_t2t$CHROM_T2T, IRanges(gwas_t2t$start, gwas_t2t$end), 
                        snp= gwas_t2t$SNPS, trait=gwas_t2t$DISEASE.TRAIT, gene=gwas_t2t$MAPPED_GENE)
head(gwas_t2t_bed)

# Create contigs bed file
contig_bed <- GRanges(contig$chr, IRanges(contig$start, contig$end), contig_name = contig$contig_id)
head(contig_bed)

# Find overlapping intervals between the 2 files
hits <- findOverlaps(contig_bed,gwas_t2t_bed)
contig_hits <- as.data.frame(contig_bed[queryHits(hits)])
gwas_hits <- as.data.frame(gwas_t2t_bed[subjectHits(hits)])

overlapping_intervals <- unique(cbind(contig_hits,gwas_hits))
head(overlapping_intervals)

# Save file
write.csv(overlapping_intervals, "contigs_gwas-hits_overlap_t2t.csv",
          row.names = F)
