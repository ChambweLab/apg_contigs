#!/usr/bin/env bash

set -euo pipefail

# --------------------------------------------------
# Script: summarize_augustus_predictions.sh
# Description:
#   Summarize AUGUSTUS gene predictions into gene-level and contig-level tables.
#
# Input:
#   - btc_augustus_protein.gff3
#   - btc_contigs.fasta.fai
#
# Output:
#   - phase1_augustus_genes.tsv
#   - phase1_augustus_contigs.tsv
# --------------------------------------------------

BTC_FA="/path/to/btc_contigs.fasta"
PROJECT_DIR="/path/to/btc_characterization"
RESULTS_DIR="/path/to/btc_characterization/apg_gene_predictions"

GFF_FILE="${RESULTS_DIR}/btc_augustus_protein.gff3"
FAI_FILE="${BTC_FA}.fai"

GENES_OUT="${RESULTS_DIR}/phase1_augustus_genes.tsv"
CONTIGS_OUT="${RESULTS_DIR}/phase1_augustus_contigs.tsv"

mkdir -p logs

python3 scripts/phase1_augustus_count.py \
  --gff "$GFF_FILE" \
  --fai "$FAI_FILE" \
  --genes_out "$GENES_OUT" \
  --contigs_out "$CONTIGS_OUT"

