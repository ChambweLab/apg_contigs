#!/usr/bin/env bash
#SBATCH --job-name=apg_hprc_align
#SBATCH --partition=cpuq
#SBATCH --array=1-4
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH --output=logs/%x_%A_%a.out
#SBATCH --error=logs/%x_%A_%a.err

set -euo pipefail

# Purpose:
# Align APG contigs to a list of HPRC linear assembly references using a Slurm array job.
# Each array task processes one reference FASTA path from REF_PATHS_FILE.
#
# Inputs:
#   - APG contig FASTA
#   - A text file with one reference FASTA path per line
#
# Outputs:
#   - One SAM file per reference assembly
#   - A progress log recording completed tasks
#
# Example:
#   CONTIG_PATH=data/contigs/apg_contigs.fasta \
#   REF_PATHS_FILE=config/refPathsRetry.txt \
#   OUT_DIR=results/alignment/apg_hprc \
#   sbatch --array=1-4 align_apg_to_hprc_array.sh

THREADS="${SLURM_CPUS_PER_TASK:-8}"

# User-configurable paths
CONTIG_PATH="${CONTIG_PATH:-data/contigs/apg_contigs.fasta}"
REF_PATHS_FILE="${REF_PATHS_FILE:-refPathsRetry.txt}"
OUT_DIR="${OUT_DIR:-results/alignment/apg_hprc}"
LOG_DIR="${LOG_DIR:-logs}"
PROGRESS_FILE="${OUT_DIR}/progress.log"

mkdir -p "${OUT_DIR}" "${LOG_DIR}"

echo "[$(date)] Starting APG-to-HPRC alignment array task"
echo "Job ID: ${SLURM_JOB_ID:-NA}"
echo "Array task ID: ${SLURM_ARRAY_TASK_ID:-NA}"
echo "Node: ${SLURM_NODELIST:-NA}"
echo "Threads: ${THREADS}"
echo "Contig FASTA: ${CONTIG_PATH}"
echo "Reference list: ${REF_PATHS_FILE}"
echo "Output directory: ${OUT_DIR}"

module purge
module load EBModules
module load BWA/0.7.17-GCC-10.2.0

echo "[$(date)] Loaded modules:"
module list 2>&1

# Validate required inputs
[[ -f "${CONTIG_PATH}" ]] || { echo "ERROR: Contig FASTA not found: ${CONTIG_PATH}" >&2; exit 1; }
[[ -f "${REF_PATHS_FILE}" ]] || { echo "ERROR: Reference path list not found: ${REF_PATHS_FILE}" >&2; exit 1; }

TASK_ID="${SLURM_ARRAY_TASK_ID:-}"
[[ -n "${TASK_ID}" ]] || { echo "ERROR: SLURM_ARRAY_TASK_ID is not set" >&2; exit 1; }

# Extract the reference path corresponding to the current array task
REF_PATH="$(sed -n "${TASK_ID}p" "${REF_PATHS_FILE}")"
[[ -n "${REF_PATH}" ]] || { echo "ERROR: No reference path found for array task ${TASK_ID}" >&2; exit 1; }
[[ -f "${REF_PATH}" ]] || { echo "ERROR: Reference FASTA not found: ${REF_PATH}" >&2; exit 1; }

REF_BASENAME="$(basename "${REF_PATH}")"
REF_PREFIX="${REF_BASENAME%.fa.gz}"
REF_PREFIX="${REF_PREFIX%.fasta.gz}"
REF_PREFIX="${REF_PREFIX%.fa}"
REF_PREFIX="${REF_PREFIX%.fasta}"

OUT_SAM="${OUT_DIR}/${REF_PREFIX}.sam"

echo "[$(date)] Processing reference: ${REF_PATH}"
echo "[$(date)] Output SAM: ${OUT_SAM}"

# Align APG contigs to the selected HPRC reference
bwa mem -t "${THREADS}" "${REF_PATH}" "${CONTIG_PATH}" > "${OUT_SAM}"

# Record successful completion in the progress log
echo "[$(date)] Task ${TASK_ID} completed: ${OUT_SAM}" >> "${PROGRESS_FILE}"

echo "[$(date)] Array task ${TASK_ID} finished successfully"
