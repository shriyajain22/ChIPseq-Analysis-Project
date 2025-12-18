#!/usr/bin/env nextflow

process POS2BED {
    label 'process_medium'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir "${params.outdir}/pos2bed", mode: "copy"

    input:
    tuple val(rep), path("${rep}_peaks.txt")

    output:
    tuple val(rep), path("${rep}_peaks.bed")

    script: 
    """
    pos2bed.pl ${rep}_peaks.txt> ${rep}_peaks.bed
    """

    stub:
    """
    touch ${homer_txt.baseName}.bed
    """
}


