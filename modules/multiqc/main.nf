#!/usr/bin/env nextflow

process MULTIQC {
    label 'process_high'
    container 'ghcr.io/bf528/multiqc:latest'
    publishDir "${params.outdir}/multiqc", mode: "copy"

    input:
    path ("*")  
    
    output:
    path "multiqc_report.html", emit: report
    
    script:
    """
     multiqc . -f -o .
    """
    
    stub:
    """
    touch multiqc_report.html
    """
}