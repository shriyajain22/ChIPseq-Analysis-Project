#!/usr/bin/env nextflow

process PLOTCORRELATION {
    label 'process_high'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir "${params.outdir}/deeptools_plotCorrelation", mode: "copy"

    input:
    path (bigwig_npz)

    output:
    path "correlation_heatmap.pdf", emit: heatmap
    path "correlation_matrix.tab", emit: table

    script:
    """
    
    plotCorrelation \
        --corData ${bigwig_npz} \
        --corMethod pearson \
        --whatToPlot heatmap \
        --plotNumbers \
        --removeOutliers \
        --plotFile correlation_heatmap.pdf \
        --outFileCorMatrix correlation_matrix.tab
    """

    stub:
    """
    touch correlation_plot.png
    """
}






