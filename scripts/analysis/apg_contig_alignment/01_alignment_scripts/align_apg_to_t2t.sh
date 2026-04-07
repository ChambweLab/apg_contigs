#!/usr/bin/env bash
#SBATCH --job-name=apg_t2t_align
#SBATCH --partition=cpuq
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

# Purpose:
# Align APG contigs to the T2T-CHM13 reference assembly using BWA-MEM.
#
# Inputs:
#   - Reference FASTA (T2T-CHM13)
#   - APG contig FASTA
#
# Outputs:
#   - Sorted and indexed BAM file

THREADS="${SLURM_CPUS_PER_TASK:-8}"

# ==============================
# User-defined inputs (EDITABLE)
# ==============================

REF_PATH="${REF_PATH:-data/reference/t2t_chm13.fasta}"
CONTIG_PATH="${CONTIG_PATH:-data/contigs/apg_contigs.fasta}"
OUT_DIR="${OUT_DIR:-results/alignment/apg_t2t}"

LOG_DIR="${OUT_DIR}/logs"
mkdir -p "${OUT_DIR}" "${LOG_DIR}"

echo "[$(date)] Starting APG-to-T2T alignment"
echo "Job ID: ${SLURM_JOB_ID:-NA}"
echo "Node: ${SLURM_NODELIST:-NA}"
echo "Threads: ${THREADS}"
echo "Reference: ${REF_PATH}"
echo "Contigs: ${CONTIG_PATH}"
echo "Output directory: ${OUT_DIR}"

# ==============================
# Load modules
# ==============================

module purge
module load EBModules
module load BWA/0.7.17-GCC-10.2.0
module load SAMtools/1.16.1-GCC-11.3.0

echo "[$(date)] Loaded modules:"
module list 2>&1

# ==============================
# Input validation
# ==============================

[[ -f "${REF_PATH}" ]] || { echo "ERROR: Reference FASTA not found: ${REF_PATH}" >&2; exit 1; }
[[ -f "${CONTIG_PATH}" ]] || { echo "ERROR: Contig FASTA not found: ${CONTIG_PATH}" >&2; exit 1; }

# ==============================
# Output definitions
# ==============================

OUT_PREFIX="${OUT_DIR}/apg_vs_t2t_chm13"
OUT_SAM="${OUT_PREFIX}.sam"
OUT_BAM="${OUT_PREFIX}.sorted.bam"

# ==============================
# Alignment
# ==============================

echo "[$(date)] Running BWA-MEM"
bwa mem -t "${THREADS}" "${REF_PATH}" "${CONTIG_PATH}" > "${OUT_SAM}"

# ==============================
# Post-processing
# ==============================

echo "[$(date)] Converting SAM to sorted BAM"
samtools sort -@ "${THREADS}" -o "${OUT_BAM}" "${OUT_SAM}"

echo "[$(date)] Indexing BAM"
samtools index "${OUT_BAM}"

echo "[$(date)] Cleaning up intermediate files"
rm -f "${OUT_SAM}"

echo "[$(date)] Alignment complete"
echo "Final BAM: ${OUT_BAM}"
