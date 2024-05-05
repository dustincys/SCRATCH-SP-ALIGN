//
// Description
//

include { SAMPLESHEET_CHECK        } from '../../modules/local/helper/samplesheet_check/main.nf'
include { CELLRANGER_COUNT         } from '../../modules/local/cellranger/count/main'
include { CELLRANGER_VDJ           } from '../../modules/local/cellranger/vdj/main'
// include { SCBTC_INDEX              } from '../../modules/local/btcmodules/indexes/main'
// include { SCBTC_FILTERING          } from '../../modules/local/btcmodules/filtering/main'
// include { SCBTC_QCRENDER           } from '../../modules/local/btcmodules/report/main'

workflow SCRATCH_ALIGN {

    take:
        ch_sample_table // channel: [ val(sample), [ fastq ] ]
        genome          // string: genome code

    main:

        // Channel definitions
        ch_versions  = Channel.empty()

        // Quarto notebooks

        // Sample check
        ch_sample_table = SAMPLESHEET_CHECK(ch_sample_table)
            .csv
            .splitCsv(header:true, sep:',')
            .map{ row -> tuple row.sample, row.fastq_1, row.fastq_2 }

        // Grouping fastq based on sample id
        ch_samples_grouped = ch_sample_table
            .map { row -> tuple row[0], row[1], row[2] }
            .groupTuple(by: [0])
            .map { row -> tuple row[0], row[1 .. 2].flatten() }

        // Retrieving Cellranger Counts indexes
        gex_indexes = params.genomes[genome].gex

        // Retrieving Cellranger VDJ reference
        // vdj_indexes = params.genomes[genome].vdj

        // Cellranger gex alignment
        ch_gex_alignment = CELLRANGER_COUNT(
            ch_samples_grouped, 
            gex_indexes
        )

        // ch_gex_alignment.outs
        //     .view()

        // Cellranger gex alignment
        // ch_vdj_alignment = CELLRANGER_VDJ(
        //     ch_samples_grouped,
        //     vdj_indexes
        // )

    emit:
        ch_versions = ch_versions // channel: [ objects ]

}