
#!/usr/bin/env bash
#SBATCH --job-name=repeatmasker_btc
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

# --------------------------------------------------
# Script: run_repeatmasker_contig_sets.sh
# Description:
#   Run RepeatMasker on BTC or related contig sets for repeat profiling.
#
# Input:
#   Contig FASTA files listed below
#
# Output:
#   RepeatMasker output files in repeatmasker_results/
# --------------------------------------------------

module load EBModules
module load RepeatMasker  ## version 4.1.5

BTC_FA="/path/to/btc_contigs.fasta"
PROJECT_DIR="/path/to/btc_characterization"
RESULTS_DIR="/path/to/btc_characterization/apg_gene_predictions"

cd "$PROJECT_DIR"
mkdir -p repeatmasker_results logs

echo "RepeatMasker started"
echo `date`

# Uncomment the contig set you want to process

# RepeatMasker -species human -pa 8 -dir repeatmasker_results/ "$BTC_FA"
# RepeatMasker -species human -pa 8 -dir repeatmasker_results/ remain_unmapped_contigs_fasta.fa
# RepeatMasker -species human -pa 8 -dir repeatmasker_results/ hprc_n_unmapped_contigs.fasta.fa
RepeatMasker -species human -pa 8 -dir repeatmasker_results/ hprc_only_mapped_contigs.fasta.fa
# RepeatMasker -species human -pa 8 -dir repeatmasker_results/ t2t_hprc_rg_mapped_contigs_fasta.fa

echo "RepeatMasker completed"
echo `date`

