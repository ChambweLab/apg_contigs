#!/bin/bash

# Activate/load nextflow version 25.10.0 and nf-core/rnaseq 3.21.0

# Set up paths
INPUT="grch38_unmapped_reads_sample-sheet.csv"
OUTPUT="out_path/alignment_results_grch38Unmapped_to_btc" 
FASTA="btc_contigs_fixed.fasta" # .fasta file containing BTC sequence to be used as reference 
GTF="btc_augustus_protein.gtf" # AUGUSTUS gene predictions for BTC --> to be used for gene quentification

# ------------------------
# Run nf-core/rnaseq
# ------------------------
nextflow run nf-core/rnaseq \
    -c salmon_quant.config \
    -profile singularity \
    --input "$INPUT" \
    --outdir "$OUTPUT" \
    --fasta "$FASTA" \
    --gtf "$GTF" \
    --trimer trimgalore \
    --aligner star_rsem \
    --save_align_intermeds \
    --skip_bigwig false \
    --remove_ribo_rna \
    --skip_stringtie \
    --save_reference \
    --skip_gtf_filter \
    --skip_gtf_transcript_filter 
