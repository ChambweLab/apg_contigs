# Functional Potential of African Pangenome Sequences

This repository contains code for the study of functional potential of African Pangenome Contig (APG) Sequences that are still absent from reference genomes. 
Study preprint can be found here: <https://doi.org/10.1101/2025.08.15.670543>

<img width="3000" height="2100" alt="APG-Contigs-Schematic-Vertical_v4" src="https://github.com/user-attachments/assets/a956379f-d8be-4b4f-8e25-06da2d261039" />

## Repository structure

    scripts/   
        analysis/   # scripts for all analyses
            apg_contig_alignment/ # aligning apg-contigs to reference genomes
                01_alignment_scripts/ # scripts for aligning apg-contigs to T2T-CHM13 & HPRC assemblies
                02_alignment_characterization/ # scripts for downstream analysis of T2T-CHM13 alignment results
                    t2t_apg-contig_enrichment/
            rna_seq_pipeline/ # apg-contig expression across 3 diverse cohorts
                01_run_alignment_scripts/ # RNAseq alignment code
                02_analyzing_alignment_results/ # code for downstream analysis of RNAseq alignment results
            unmapped_contig_characterization/ # scripts for functional characterization of unmapped (BTC) contigs
                01_repeatmasker/
                02_gene_prediction/
                03_cpg_islands/
                04_protein_domain_annotation/
                05_blastp_annotation/
        figures/    # scripts for generation of the main paper figures

## Main figures

- **Figure 1** — Study design (Generated using Biorender)
- **Figure 2** — Summary of APG contigs alignment to T2T-CHM13
- **Figure 3** — Distribution of functional feature overlap of T2T-CHM13 mapped contigs
- **Figure 4** — Population and individual sharing summary of APG contig alignment across HPRC assemblies
- **Figure 5** — Functional characterization of APG contigs unmapped to gapless reference assemblies (BTC)

Notes
* This repository is intended to provide study-related code.
* Generated figures, raw data, large intermediate files, and local outputs are not committed.
* Figure-specific code is organized in the corresponding scripts/figures/fig.*/ directory.
