# ChIP-seq Analysis Project

This project implements a reproducible ChIP-seq (Chromatin Immunoprecipitation Sequencing) analysis workflow for identifying protein–DNA binding regions and characterizing genomic enrichment patterns in human cell lines. The pipeline integrates sequencing quality control, genome alignment, peak calling, motif enrichment analysis, genomic signal visualization, and downstream biological interpretation using Nextflow-based bioinformatics workflows.

ChIP-seq is a widely used epigenomics technique that enables the identification of DNA-binding protein interaction sites, regulatory elements, and transcription factor occupancy across the genome.

## Project Objectives

The primary goals of this project were to:
- Process and analyze raw ChIP-seq sequencing data
- Perform sequencing quality control and alignment analysis
- Generate normalized genomic coverage tracks
- Identify enriched protein–DNA binding regions
- Generate reproducible peak sets across biological replicates
- Perform motif enrichment and genomic annotation analysis
- Reproduce and compare results from the original publication
- Develop reproducible and scalable bioinformatics workflows

## Workflow Overview

The analysis pipeline consists of the following major steps:

### 1. Data Acquisition
- Downloading ChIP-seq datasets from the published study
- Organizing IP and INPUT paired replicate samples

### 2. Quality Control
Sequencing quality assessment and preprocessing included:
- `FastQC`
- `MultiQC`
- `Trimmomatic`

This step evaluated:
- Read quality
- Adapter contamination
- Low-quality sequencing regions

### 3. Read Alignment
Sequencing reads were aligned to the hg38 human reference genome using:
- `Bowtie2`
- `samtools`

Additional processing steps included:
- BAM sorting and indexing
- Alignment statistics generation using `samtools flagstat`

### 4. Coverage Track Generation
Normalized genomic coverage tracks were generated using:
- `deeptools bamCoverage`

Coverage tracks were stored in bigWig format for downstream visualization and signal analysis.

### 5. Correlation Analysis
Sample similarity and experiment reproducibility were evaluated using:
- `multiBigwigSummary`
- `plotCorrelation`

Correlation plots were generated to compare biological replicates and INPUT controls.

### 6. Peak Calling
Protein–DNA binding regions were identified using:
- `HOMER makeTagDirectory`
- `HOMER findPeaks`

Peak calling was performed independently for replicate IP/INPUT sample pairs.

### 7. Reproducible Peak Generation
Consensus reproducible peaks were generated using:
- `bedtools intersect`

Additional filtering steps included:
- Removal of ENCODE blacklist regions
- Peak reproducibility filtering across replicates

### 8. Peak Annotation
Filtered peaks were annotated to their nearest genomic features using:
- `HOMER annotatePeaks.pl`

### 9. Signal Intensity Visualization
Genomic signal enrichment across gene regions was visualized using:
- `computeMatrix`
- `plotProfile`

Signal intensity plots were generated relative to transcription start sites (TSS) and transcription termination sites (TTS).

### 10. Motif Enrichment Analysis
Motif enrichment analysis was performed using:
- `HOMER findMotifsGenome.pl`

This analysis identified enriched transcription factor binding motifs within reproducible peak regions.

### 11. Biological Interpretation & Figure Reproduction
Downstream analysis included:
- Correlation heatmaps
- Peak overlap analysis
- Motif enrichment visualization
- Genomic track visualization
- Comparison with RNA-seq datasets
- Reproduction of selected publication figures

## Tools & Technologies

### Programming & Workflow
`Python` `R` `Bash` `Nextflow` `Docker` `Conda`

### Bioinformatics Tools
`FastQC` `MultiQC` `Trimmomatic`  
`Bowtie2` `samtools` `bedtools`  
`deeptools` `HOMER`

### Statistical & Visualization Packages
`ggplot2` `matplotlib` `pandas`

## Repository Structure

```bash
ChIPseq-Analysis-Project/
│
├── bin/                        # Helper scripts
├── env/                        # Environment configuration files
├── modules/                    # Nextflow modules
├── results/                    # Workflow outputs and figures
├── figures.ipynb               # Figure generation notebook
├── project3_analysis.ipynb     # Main analysis notebook
├── project3_analysis.html      # Rendered analysis report
├── main.nf                     # Main Nextflow workflow
├── nextflow.config             # Workflow configuration
├── full_samplesheet.csv        # Full dataset metadata
├── subsampled_samplesheet.csv  # Subsampled dataset metadata
├── hg38_genes.bed              # Gene annotation BED file
└── README.md
```
## Citation

This workflow was implemented using datasets and analysis concepts from the following publication:  
Barutcu, A. R., Hong, D., Lajoie, B. R., McCord, R. P., van Wijnen, A. J., Lian, J. B., Stein, J. L., Dekker, J., Imbalzano, A. N., & Stein, G. S. (2016). RUNX1 contributes to higher-order chromatin organization and gene regulation in breast cancer cells. *Biochimica et biophysica acta*, 1859(11), 1389–1397. https://doi.org/10.1016/j.bbagrm.2016.08.003

Note: This project was developed as part of the Genomic Data Analysis (BF528) coursework at Boston University.
