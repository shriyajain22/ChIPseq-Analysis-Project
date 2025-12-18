#!/usr/bin/env nextflow

process FIND_MOTIFS_GENOME {
    label 'process_medium'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir "${params.outdir}/motifs", mode: "copy"

    input:
    path(genome)
    path(peaks)

    output:
    path("motif_results")

    script:
    """
    findMotifsGenome.pl \
        ${peaks} \
        ${genome} \
        motif_results \
        -size given
    """

    stub:
    """
    mkdir motifs
    """
}


