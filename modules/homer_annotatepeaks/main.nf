#!/usr/bin/env nextflow

process ANNOTATE {
    label 'process_high'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    path(peaks)
    path(gtf)

    output:
    path("annotated_peaks.txt"), emit: annotated

    script:
    """
    annotatePeaks.pl ${peaks} \
    none \
    -gtf ${gtf} \
    > annotated_peaks.txt
    """
    
    stub:
    """
    touch annotated_peaks.txt
    """
}



