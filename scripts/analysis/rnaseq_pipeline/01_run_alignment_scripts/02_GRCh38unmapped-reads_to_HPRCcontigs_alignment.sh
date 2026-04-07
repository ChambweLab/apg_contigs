#!/bin/bash

# To run this analysis you will need STAR v2.7.11b installed

# 1. Build STAR index (no GTF file availble --> skipping gene quantification step)
mkdir -p hprc_contigs_star_index

STAR \
  --runThreadN 16 \
  --runMode genomeGenerate \
  --genomeDir hprc_contigs_star_index \
  --genomeFastaFiles hprc_uniq_np_apg_contigs.fasta \ # .fasta file with sequence of HPRC-maped only contigs
  --genomeSAindexNbases 11 \
  --limitGenomeGenerateRAM 40000000000

# Check if index generation succeeded
if [ $? -ne 0 ]; then
  echo "ERROR: STAR index generation failed"
  exit 1
fi

# 2. Align paired end samples 
MANIFEST="manifest_p1kg_grch38_unmapped.json" # Manifest file with samples to run alignment on
GENOME_DIR="hprc_contigs_star_index"
OUTDIR="STAR_grch38Unmapped_to_HPRCcontigs"
THREADS=16

mkdir -p "$OUTDIR"

# Process samples
jq -c '.[]' "$MANIFEST" | while read -r row; do
  sample_id=$(echo "$row" | jq -r '.sample_id')
  r1=$(echo "$row" | jq -r '.r1')
  r2=$(echo "$row" | jq -r '.r2')

  sample_out="$OUTDIR/$sample_id"
  mkdir -p "$sample_out"

  echo "Processing: $sample_id"

  STAR \
    --runThreadN "$THREADS" \
    --genomeDir "$GENOME_DIR" \
    --readFilesIn "$r1" "$r2" \
    --readFilesCommand zcat \
    --outFileNamePrefix "$sample_out/${sample_id}_" \
    --outSAMtype BAM SortedByCoordinate \
    --outWigType bedGraph
    
  if [ $? -eq 0 ]; then
    echo "✓ Completed: $sample_id"
  else
    echo "✗ Failed: $sample_id"
  fi
done 
