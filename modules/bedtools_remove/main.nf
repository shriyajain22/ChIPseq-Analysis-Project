#!/usr/bin/env nextflow

process BEDTOOLS_REMOVE {
   label 'process_medium'
   container 'ghcr.io/bf528/bedtools:latest'
   publishDir params.outdir, mode: "copy"

   input:
   path(peaks_bed)
   path blacklist

   output:
   path("repr_cleaned_peaks.bed")

   script:
   """
   bedtools intersect \
    -v \
    -a ${peaks_bed} \
    -b ${blacklist} \
    > repr_cleaned_peaks.bed
    """

    stub:
    """
    touch repr_peaks_filtered.bed
    """
}