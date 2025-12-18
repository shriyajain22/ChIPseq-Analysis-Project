#!/usr/bin/env nextflow

process TRIM {
    label 'process_medium'
    container 'ghcr.io/bf528/trimmomatic:latest'
    publishDir "${params.outdir}/trimmed_reads", mode: "copy"

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_stub_trimmed.fastq.gz"), emit: trimmed_reads
    path "${sample_id}_stub_trim.log", emit: log

    script:
    """
    trimmomatic SE \\
      -threads ${task.cpus ?: 1} -phred33 \\
      ${reads} ${sample_id}_stub_trimmed.fastq.gz \\
      ILLUMINACLIP:/usr/share/trimmomatic/adapters/TruSeq3-SE.fa:2:30:10 \\
      LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \\
      -trimlog ${sample_id}_stub_trim.log
    
    """

    stub:
    """
    touch ${sample_id}_stub_trim.log
    touch ${sample_id}_stub_trimmed.fastq.gz
    """
}
