#!/usr/bin/env bash
#SBATCH --job-name=hmmscan_btc
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=08:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

# --------------------------------------------------
# Script: run_hmmscan_pfam.sh
# Description:
#   Annotate BTC predicted proteins with Pfam domains using hmmscan.
#
# Input:
#   - btc_augustus_protein.faa
#   - Pfam-A.hmm
#
# Output:
#   - pfam_hits.tbl
#   - pfam_scan.out
# --------------------------------------------------

module load EBModules
module load HMMER ## version 3.3.2

BTC_FA="/path/to/btc_contigs.fasta"
PROJECT_DIR="/path/to/btc_characterization"
RESULTS_DIR="/path/to/btc_characterization/apg_gene_predictions"

PFAM_DB="/path/to/Pfam-A.hmm"
PROTEIN_FASTA="${RESULTS_DIR}/btc_augustus_protein.faa"
OUT_DIR="${PROJECT_DIR}/hmmscan"

mkdir -p "$OUT_DIR" logs

hmmscan \
  --cpu 4 \
  --domtblout "${OUT_DIR}/btc_pfam_hits.tbl" \
  "$PFAM_DB" \
  "$PROTEIN_FASTA" \
  > "${OUT_DIR}/btc_augustus_protein_pfam_scan.out"

