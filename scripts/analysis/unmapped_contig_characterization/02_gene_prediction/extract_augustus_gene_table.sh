#!/usr/bin/env bash

set -euo pipefail

# --------------------------------------------------
# Script: extract_augustus_gene_table.sh
# Description:
#   Extract gene-level coordinates and lengths from AUGUSTUS GFF3 output.
#
# Input:
#   btc_augustus_protein.gff3
#
# Output:
#   phase1_augustus_genes.tsv
# --------------------------------------------------

BTC_FA="/path/to/btc_contigs.fasta"
PROJECT_DIR="/path/to/btc_characterization"
RESULTS_DIR="/path/to/btc_characterization/apg_gene_predictions"

GFF_FILE="${RESULTS_DIR}/btc_augustus_protein.gff3"
OUT_TSV="${RESULTS_DIR}/phase1_augustus_genes.tsv"

mkdir -p logs

awk -F'\t' 'BEGIN{OFS="\t"}
  $3=="gene"{
    gene_id="";
    if (match($9, /ID=([^;]+)/, a)) gene_id=a[1];
    len = $5 - $4 + 1;
    print $1, gene_id, $4, $5, $7, len
  }' "$GFF_FILE" > "$OUT_TSV"

sed -i '1i contig\tgene_id\tgene_start\tgene_end\tgene_strand\tgene_length_bp' "$OUT_TSV"
