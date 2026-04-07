#!/usr/bin/env bash
#SBATCH --job-name=hprc_download_index
#SBATCH --partition=cpuq
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

# Purpose:
# Download HPRC linear assembly FASTA files listed in a TSV file,
# decompress them, and build BWA indices for each assembly.
#
# Expected TSV format:
#   filename<TAB>url<TAB>...
#
# Inputs can be overridden at submission time, for example:
#   TSV_FILE=path/to/downloadLinks.tsv OUT_BASE=results/hprc_assemblies sbatch download_and_index_hprc_linear_assemblies.sh

THREADS="${SLURM_CPUS_PER_TASK:-8}"

# User-configurable paths
TSV_FILE="${TSV_FILE:-downloadLinks.tsv}"
OUT_BASE="${OUT_BASE:-data/hprc_linear_assemblies}"
LOG_DIR="${LOG_DIR:-logs}"

mkdir -p "${OUT_BASE}" "${LOG_DIR}"

echo "[$(date)] Starting HPRC download and indexing job"
echo "Job ID: ${SLURM_JOB_ID:-NA}"
echo "Node: ${SLURM_NODELIST:-NA}"
echo "Threads: ${THREADS}"
echo "TSV file: ${TSV_FILE}"
echo "Output base: ${OUT_BASE}"

module purge
module load EBModules
module load BWA/0.7.17-GCC-10.2.0

echo "[$(date)] Loaded modules:"
module list 2>&1

# Check input file exists
[[ -f "${TSV_FILE}" ]] || { echo "ERROR: TSV file not found: ${TSV_FILE}" >&2; exit 1; }

# Read each line of the TSV and process one assembly at a time
while IFS=$'\t' read -r filename url rest; do
    # Skip empty lines
    [[ -n "${filename}" ]] || continue

    # Skip header line if present
    if [[ "${filename}" == "filename" ]]; then
        continue
    fi

    sample="${filename%%.*}"
    sample_dir="${OUT_BASE}/${sample}"
    gz_path="${sample_dir}/${filename}"
    fasta_path="${sample_dir}/${filename%.gz}"

    mkdir -p "${sample_dir}"

    echo "[$(date)] Processing sample: ${sample}"
    echo "  Download URL: ${url}"
    echo "  Compressed file: ${gz_path}"
    echo "  FASTA file: ${fasta_path}"

    # Download compressed FASTA if it does not already exist
    if [[ ! -f "${gz_path}" ]]; then
        echo "[$(date)] Downloading ${filename}"
        curl -L "${url}" -o "${gz_path}"
    else
        echo "[$(date)] Found existing compressed file, skipping download"
    fi

    # Decompress while keeping the original .gz file
    if [[ ! -f "${fasta_path}" ]]; then
        echo "[$(date)] Decompressing ${filename}"
        gunzip -k "${gz_path}"
    else
        echo "[$(date)] Found existing FASTA, skipping decompression"
    fi

    # Build BWA index if not already present
    if [[ ! -f "${fasta_path}.bwt" ]]; then
        echo "[$(date)] Building BWA index for ${fasta_path}"
        bwa index -a bwtsw "${fasta_path}"
    else
        echo "[$(date)] BWA index already exists, skipping indexing"
    fi

done < "${TSV_FILE}"

echo "[$(date)] HPRC download and indexing job completed"
