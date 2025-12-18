// Include your modules here
include {FASTQC} from './modules/fastqc'
include {TRIM} from './modules/trimmomatic'
include {BOWTIE2_BUILD} from './modules/bowtie2_build'
include {BOWTIE2_ALIGN} from './modules/bowtie2_align'
include {SAMTOOLS_SORT} from './modules/samtools_sort'
include {SAMTOOLS_IDX} from './modules/samtools_idx'
include {SAMTOOLS_FLAGSTAT} from './modules/samtools_flagstat'
include {BAMCOVERAGE} from './modules/deeptools_bamcoverage'
include {MULTIQC} from './modules/multiqc'
include {MULTIBWSUMMARY} from './modules/deeptools_multibwsummary'
include {PLOTCORRELATION} from './modules/deeptools_plotcorrelation'
include {TAGDIR} from './modules/homer_maketagdir'
include {FINDPEAKS} from './modules/homer_findpeaks'
include {POS2BED} from './modules/homer_pos2bed'
include {BEDTOOLS_INTERSECT} from './modules/bedtools_intersect'
include {BEDTOOLS_REMOVE} from './modules/bedtools_remove'
include {ANNOTATE} from './modules/homer_annotatepeaks'
include {FIND_MOTIFS_GENOME} from './modules/homer_findmotifsgenome'
include {PLOTPROFILE} from './modules/deeptools_plotprofile'
include {COMPUTEMATRIX} from './modules/deeptools_computematrix'

workflow {
    Channel.fromPath(params.samplesheet)
    | splitCsv( header: true )
    | map{ row -> tuple(row.name, file(row.path)) }
    | set { reads_ch }

    fastqc = FASTQC(reads_ch)
    trimmed = TRIM(reads_ch)
    genome_index = BOWTIE2_BUILD(params.genome)
    aligned = BOWTIE2_ALIGN(genome_index, TRIM.out.trimmed_reads)
    sorted_bam = SAMTOOLS_SORT(aligned)
    indexed_bam = SAMTOOLS_IDX(sorted_bam)
    flagstats = SAMTOOLS_FLAGSTAT(sorted_bam)
    bigwigs = BAMCOVERAGE(indexed_bam)
    multiqc_input = FASTQC.out.zip.mix(SAMTOOLS_FLAGSTAT.out.flagstat).mix(TRIM.out.log).collect()
    multiqc_report = MULTIQC(multiqc_input)
    bw_files = bigwigs.map { sid, bw -> bw }.collect()
    MULTIBWSUMMARY(bw_files)
    corr = PLOTCORRELATION(MULTIBWSUMMARY.out.npz)
    TAGDIR(BOWTIE2_ALIGN.out.bam)
    TAGDIR.out \
        | map { sample, tagdir ->
            def parts = sample.tokenize('_')
            if( parts.size() != 2 ) {
                throw new IllegalStateException(
                    "Sample name '${sample}' does not look like '<rep>_<cond>' or '<cond>_<rep>'"
                )
            }

            def cond_labels = ['IP','INPUT','Control','CTRL','Input','input'] as Set
            def first  = parts[0]
            def second = parts[1]

            String rep
            String cond

            if( cond_labels.contains(first) ) {
                cond = first
                rep  = second
            } else if( cond_labels.contains(second) ) {
                cond = second
                rep  = first
            } else {
                throw new IllegalStateException(
                    "Could not find condition label (IP/INPUT/Control) in sample name '${sample}'"
                )
            }

            tuple(rep, cond, tagdir)   
        } \
        | groupTuple()                 
        | map { rep, conds, tagdirs ->
            def ip_idx   = conds.findIndexOf { it.equalsIgnoreCase('IP') }
            def ctrl_idx = conds.findIndexOf { it.equalsIgnoreCase('INPUT') || it.equalsIgnoreCase('Control') || it.equalsIgnoreCase('CTRL') }

            if( ip_idx < 0 || ctrl_idx < 0 ) {
                throw new IllegalStateException(
                    "Missing IP or Control/INPUT for replicate: ${rep} (conds: ${conds})"
                )
            }

            def ip_tagdir   = tagdirs[ip_idx]
            def ctrl_tagdir = tagdirs[ctrl_idx]

            tuple(rep, ip_tagdir, ctrl_tagdir)
        } \
        | set { paired_tagdirs }

    paired_tagdirs.view()
    FINDPEAKS(paired_tagdirs)
    POS2BED(FINDPEAKS.out)
    bed_list_ch=POS2BED.out.toList()
    bed_list_ch.view()
    bed_pairs_ch=bed_list_ch.map {list ->
    def rep1 = list.find {it[0] == 'rep1'}
    def rep2 = list.find {it[0] == 'rep2'}

    tuple(
        rep1[0],
        rep1[1],
        rep2[0],
        rep2[1]
        )
    }
    bed_pairs_ch.view()
    BEDTOOLS_INTERSECT(bed_pairs_ch)
    BEDTOOLS_REMOVE(BEDTOOLS_INTERSECT.out,params.blacklist)
    ANNOTATE (BEDTOOLS_REMOVE.out, params.gtf)
    bigwig_ch=BAMCOVERAGE.out.bigwig
    ip_bigwig_ch=bigwig_ch.filter{sample, bigwig -> sample.contains("IP")}
    ip_bigwig_ch.view()
    COMPUTEMATRIX(ip_bigwig_ch, file("hg38_genes.bed"))
    PLOTPROFILE(COMPUTEMATRIX.out)
    FIND_MOTIFS_GENOME(params.genome, BEDTOOLS_REMOVE.out)


}