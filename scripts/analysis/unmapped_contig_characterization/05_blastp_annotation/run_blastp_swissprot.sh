#!/usr/bin/env bash
#SBATCH --job-name=blastp_btc
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=08:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

# --------------------------------------------------
# Script: run_blastp_swissprot.sh
# Description:
#   Run BLASTP of BTC predicted proteins against SwissProt.
#
# Input:
#   btc_augustus_protein.faa
#
# Output:
#   augustus_vs_swissprot.tsv
# --------------------------------------------------

module load EBModules
module load BLAST+ ## 2.13.0+

BTC_FA="/path/to/btc_contigs.fasta"
PROJECT_DIR="/path/to/btc_characterization"
RESULTS_DIR="/path/to/btc_characterization/apg_gene_predictions"

QUERY_FASTA="${RESULTS_DIR}/btc_augustus_protein.faa"
OUT_DIR="${PROJECT_DIR}/blastp"

mkdir -p "$OUT_DIR" logs

blastp \
  -query "$QUERY_FASTA" \
  -db swissprot_db \
  -evalue 1e-3 \
  -max_target_seqs 20 \
  -num_threads 8 \
  -outfmt "6 qseqid sseqid pident length evalue bitscore qcovhsp stitle" \
  > "${OUT_DIR}/augustus_vs_swissprot.tsv"

