#!/usr/bin/env nextflow

process FASTQC {
    label 'process_low'
    container 'ghcr.io/bf528/fastqc:latest'
    publishDir "${params.outdir}/fastqc", mode: "copy"

    input:
    tuple val(sample), path(fastq)

    output:
    tuple val(sample), path("*.html"), emit: html
    path("*.zip"), emit: zip

    script:
    """
    fastqc -t $task.cpus $fastq
    """

    stub:
    """
    touch stub_${sample_id}_fastqc.zip
    touch stub_${sample_id}_fastqc.html
    """
}