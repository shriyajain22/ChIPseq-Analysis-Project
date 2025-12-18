#!/usr/bin/env nextflow

process BOWTIE2_BUILD {
    label 'process_high'
    container 'ghcr.io/bf528/bowtie2:latest'
    publishDir "${params.outdir}/bowtie2_index", mode: "copy"

    input:
    path reference      
    
    output:
    path "bowtie2_index", emit: index

    script:
    """
    mkdir -p bowtie2_index
    bowtie2-build ${reference} bowtie2_index/genome_index
    """

    stub:
    """
    mkdir bowtie2_index
    """
}