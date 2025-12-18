#!/usr/bin/env nextflow

process BEDTOOLS_INTERSECT {
    label 'process_medium'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(rep1_label), path(rep1_bed), val(rep2_label), path(rep2_bed)

    output:
    path("reproducible_peaks.bed"), emit: reproducible_peaks

    script:
    """
    bedtools intersect -a ${rep1_bed} -b ${rep2_bed} -f 0.5 -r > reproducible_peaks.bed
    """
    
    stub:
    """
    touch repr_peaks.bed
    """
}