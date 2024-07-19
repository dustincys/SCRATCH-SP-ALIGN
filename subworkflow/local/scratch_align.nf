//
// Description
//

include { SAMPLESHEET_CHECK        } from '../../modules/local/helper/validate/main.nf'
include { SPACERANGER_COUNT         } from '../../modules/local/spaceranger/count/main.nf'
include { SPACERANGER_MKFASTQ           } from '../../modules/local/spaceranger/mkfastq/main.nf'

// Importing Quarto notebooks

workflow SCRATCH_ALIGN {

    take:
        ch_sample_table // channel: [ val(sample), [ fastq ] ]
        modality        // string: GEX, TCR, or GEX+TCR
        genome          // string: genome code

    main:

        // Channel definitions
        ch_versions  = Channel.empty()

        // Quarto settings
        ch_template    = Channel.fromPath(params.template, checkIfExists: true)
            .collect()

        ch_page_config = Channel.fromPath(params.page_config, checkIfExists: true)
            .collect()

        ch_page_config = ch_template
            .map{ file -> file.find { it.toString().endsWith('.png') } }
            .combine(ch_page_config)
            .collect()

        // Sample check
        ch_sample_table = SAMPLESHEET_CHECK(ch_sample_table)
            .csv
            .splitCsv(header:true, sep:',')
            .map{ row -> tuple row.sample, row.fastq_1, row.fastq_2, row.modality }

        ch_sample_table
            .view()

        // Separeting GEX and MKFASTQ
        ch_sample_branches = ch_sample_table
            .branch {
                gex: it[3] == 'GEX'
                tcr: it[3] == 'TCR'
            }
        
        // Printing out warnings
        ch_sample_branches.gex
            .ifEmpty { 
                println("No GEX samples were found. Skipping SPACERANGER_COUNTS process.")
            }

        ch_sample_branches.tcr
            .ifEmpty { 
                println("No TCR samples were found. Skipping SPACERANGER_MKFASTQ process.")
            }

        if(modality =~ /\b(GEX)/) {

            // Staging Cellranger Counts indexes
            gex_indexes = params.genomes[genome].gex

            // Grouping fastq based on sample id
            ch_gex_grouped = ch_sample_branches.gex
                .map { row -> tuple row[0], row[1], row[2] }
                .groupTuple(by: [0])
                .map { row -> tuple row[0], row[1 .. 2].flatten() }

            // Cellranger gex alignment
            ch_gex_alignment = SPACERANGER_COUNT(
                ch_gex_grouped,
                gex_indexes
            ) 

            ch_cellrange_outs = ch_gex_alignment.outs

        }

        if(modality =~ /\b(TCR)/) {

            // Staging Cellranger MKFASTQ reference
            mkfastq_indexes = params.genomes[genome].mkfastq

            // Grouping fastq based on sample id
            ch_tcr_grouped = ch_sample_branches.tcr
                .map { row -> tuple row[0], row[1], row[2] }
                .groupTuple(by: [0])
                .map { row -> tuple row[0], row[1 .. 2].flatten() }

            // Cellranger gex alignment
            ch_tcr_alignment = SPACERANGER_MKFASTQ(
                ch_tcr_grouped,
                mkfastq_indexes
            )

            ch_cellrange_outs = ch_tcr_alignment.outs

        }
        

        if(modality =~ /\b(GEX+TCR)/) {

            ch_cellrange_outs = ch_gex_alignment.outs

        }

    emit:
        ch_cellrange_outs

}
