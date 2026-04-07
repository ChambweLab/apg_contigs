#!/bin/bash  
#SBATCH --mem=2.5G  
#SBATCH --cpus-per-task=16  
#SBATCH --array=0-6  
#SBATCH --job-name=intersect_t2t-elements_apg-contigs  
#SBATCH --output=bedtools_intersect_%A_%a.out  
#SBATCH --error=bedtools_intersect_%A_%a.err

# You will need to have bedtools installed to run this script

# Define paths  
PATH1="path_to_apg-contigs_t2t_alignments" # T2T-CHM13 locations of apg contigs  
PATH2="path_to_t2t_annotation_files"  # Path to T2T-CHM13 annotation file that have been previously downloaded
OUT_PATH="outpath/t2t-elements_apg-contigs_intersection"

# Single input file  
INPUT="${PATH1}/all_apg_contigs_alignments_t2t.bed"

# Annotation files  
ANNOTATION_FILES=(  
    "chm13v2.0_RepeatMasker_4.1.2p1.2022Apr14.bed"  
    "T2T_Genes_t2t.bed"  
    "Difficult_Regions_T2T.bed"  
    "T2T_CGIs_Unmasked.bed"  
    "chm13v2-unique_to_hg38.bed"  
    "chm13v2.0_censat_v2.1.bed"  
    "chm13v2.0_composite-repeats_2022DEC.bed"  
)

# Output files  
OUTPUT_FILES=(  
    "contigs_repeat_masker_overlap_t2t.bed"  
    "contigs_genes_overlap_t2t.bed"  
    "contigs_difficult_regions_overlap_t2t.bed"  
    "contigs_CGI_overlap_t2t.bed"  
    "contigs_uniqueT2Telements_overlap_t2t.bed"  
    "contigs_CenSat_overlap_t2t.bed"  
    "contigs_CompElements_overlap_t2t.bed"  
)

# Get the current array task index  
IDX=${SLURM_ARRAY_TASK_ID}

echo "Running task ${IDX}: Intersecting with ${ANNOTATION_FILES[$IDX]}"

# Run bedtools intersect for this task  
bedtools intersect -wo \  
    -a "${INPUT}" \  
    -b "${PATH2}/${ANNOTATION_FILES[$IDX]}" \  
    > "${OUT_PATH}/${OUTPUT_FILES[$IDX]}"

echo "Task ${IDX} completed."  
