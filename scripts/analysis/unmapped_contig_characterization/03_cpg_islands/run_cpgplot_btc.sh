#!/usr/bin/env bash
#SBATCH --job-name=cpgplot_btc
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=04:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

# --------------------------------------------------
# Script: run_cpgplot_btc.sh
# Description:
#   Predict CpG islands on BTC contigs using EMBOSS cpgplot.
#
# Input:
#   BTC_FA - BTC contig FASTA
#
# Output:
#   btc_cpgplot.txt
# --------------------------------------------------

module load EBModules
module load EMBOSS  ## version 6.6.0.0

BTC_FA="/path/to/btc_contigs.fasta"
PROJECT_DIR="/path/to/btc_characterization"
RESULTS_DIR="/path/to/btc_characterization/apg_gene_predictions"

mkdir -p "${PROJECT_DIR}/cpg" logs

cpgplot \
  -sequence "$BTC_FA" \
  -outfile "${PROJECT_DIR}/cpg/btc_cpgplot.txt" \
  -graph none \
  -window 100 \
  -minlen 200 \
  -minoe 0.6 \
  -minpc 50

