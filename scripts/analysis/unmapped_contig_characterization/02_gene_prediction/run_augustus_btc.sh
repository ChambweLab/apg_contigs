#!/usr/bin/env bash
#SBATCH --job-name=augustus_btc
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

# --------------------------------------------------
# Script: run_augustus_btc.sh
# Description:
#   gene Prediction on BTC contigs using AUGUSTUS and extract
#   protein FASTA and GTF outputs.
#
# Input:
#   BTC_FA - BTC contig FASTA
#
# Output:
#   - btc_augustus_protein.gff3
#   - btc_augustus_protein.faa
#   - btc_augustus_protein.gtf
# --------------------------------------------------

module load EBModules
module load AUGUSTUS ## version 3.5.0

BTC_FA="/path/to/btc_contigs.fasta"
PROJECT_DIR="/path/to/btc_characterization"
RESULTS_DIR="/path/to/btc_characterization/apg_gene_predictions"

mkdir -p "$RESULTS_DIR" logs

augustus \
  --species=human \
  "$BTC_FA" \
  --gff3=on \
  --UTR=on \
  --outfile="${RESULTS_DIR}/btc_augustus_protein.gff3" \
  --protein=on

gffread "${RESULTS_DIR}/btc_augustus_protein.gff3" \
  -g "$BTC_FA" \
  -y "${RESULTS_DIR}/btc_augustus_protein.faa"

gffread "${RESULTS_DIR}/btc_augustus_protein.gff3" \
  -T \
  -o "${RESULTS_DIR}/btc_augustus_protein.gtf"
