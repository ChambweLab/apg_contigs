#!/bin/bash

# To run this you need Nextflow version 25.10.0 and nf-core/rnaseq 3.21.0
# The aim of this script is to obtain unaligned reads for further alignment to HPRC-mapped only contigs and BTCs

# Set up paths
INPUT="sample_sheet_rnaseq_gzip_fastqs.csv"
OUTPUT="out_path/alignment_results_GRCh38/"
FASTA="Homo_sapiens_assembly38.fasta"
GTF="gencode.v49.chr_patch_hapl_scaff.annotation.gtf.gz"

# ------------------------
# Run nf-core/rnaseq
# ------------------------
nextflow run nf-core/rnaseq \
    -profile singularity \
    --input "$INPUT" \
    --outdir "$OUTPUT" \
    --fasta "$FASTA" \
    --gtf "$GTF" \
    --trimer trimgalore \
    --aligner star_salmon \
    --save_unaligned \
    --skip_stringtie \
    --skip_bigwig \
    --skip_biotype_qc \
    --skip_deseq2_qc \
    --skip_pseudo_alignment \
    --skip_qc \
    --skip_gtf_filter  
    
