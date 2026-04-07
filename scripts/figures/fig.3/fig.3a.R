# Load libraries
library(karyoploteR)
library(GenomicRanges)
library(rtracklayer)

# Load T2T-CHM13 aligments for Nearly Perfect (np) apg-contigs
np <- read.table("np_apg_contigs_alignments.bed", 
                      header = FALSE, sep="\t",stringsAsFactors=FALSE, quote="")
colnames(np) <- c("chr", "start", "end", "name")

# Load T2T-CHM13 gene, centromere/satellite, CpG island & unique region annotations
genes <- read.table("T2T_Genes_sorted.bed",
                    header = FALSE, sep="\t",stringsAsFactors=FALSE, quote="")

cpg <- read.table("T2T_CGIs_Unmasked_sorted.bed",
                  header = FALSE, sep="\t",stringsAsFactors=FALSE, quote="")

uni <- read.table("chm13v2-unique_to_hg38.bed",
                  header = FALSE, sep="\t",stringsAsFactors=FALSE, quote="")

comp <- read.table("chm13v2.0_composite-repeats_2022DEC.bed",
                   header = FALSE, sep="\t",stringsAsFactors=FALSE, quote="")

censat <- read.table("chm13v2.0_censat_v2.1.bed",
                     header = FALSE, sep="\t",stringsAsFactors=FALSE, quote="")

## Create custom T2T-CHM13 genome karyotype
# Load t2t chromosome sizes
t2t_lengths <- read.table("hs1.chrom.sizes.txt", header = FALSE, col.names = c("chr", "length"))
head(t2t_lengths)

# Remove mitochondrial DNA length from df
hum <- t2t_lengths[-25,]
row.names(hum) <- hum$chr

# Reorder chromosomes
hum <- hum[c("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18",
             "chr19","chr20","chr21","chr22","chrX","chrY"),]

# Create custom T2T-CHM13 genome
custom_genome <- GRanges(
  seqnames = hum$chr,
  ranges = IRanges(start = 1, end = hum$length),
  strand = "*"
)

# Set up plotting parameters
pp <- getDefaultPlotParams(plot.type=1)
pp$ideogramheight <- 1  # Increase height if you want
pp$background.panel.color <- "white"  # Background color
pp$chromosome.name.col <- "black"  

# Open .pdf file to save the plot
pdf("functional_enrich_plot.pdf", width = 12, height = 10)

# Create ideogram
kp <- plotKaryotype(genome=custom_genome, 
                    plot.type = 1, 
                    plot.params = pp, 
                    chromosomes = "all",labels.plotter = NULL)  # replace with custom genome for CHM13 if available


kpAddChromosomeNames(kp, 
                     cex = 0.8,              # Font size
                     y = 0.5)               # This controls how close the chromosome names are

# Add tracks to ideogram
kpPlotRegions(kp, data=np, col="brown2", border="red", r0=0.04, r1=0.17)
kpPlotRegions(kp, data=uni, col="gold2", border=NA, r0=0.17, r1=0.27)
kpPlotRegions(kp, data=cpg, col="forestgreen", border=NA, r0=0.3, r1=0.36)
kpPlotRegions(kp, data=genes, col="dodgerblue3", border=NA, r0=0.38, r1=0.44)
kpPlotRegions(kp, data=comp, col="blueviolet", border=NA, r0=0.46, r1=0.52)
kpPlotRegions(kp, data=censat, col="darkorange3", border=NA, r0=0.54, r1=0.64)

# Add and customize legend
op <- par(cex = 1.2)
legend(x = "bottomright", fill = c("darkorange3","blueviolet","dodgerblue3", "forestgreen","gold2","brown2"),
       legend = c("Centromere/Satellite Repeats","Composite Elements","Genes", "CpG Islands","Unique T2T Regions","Contigs"))

# Close .pdf file
dev.off()