#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { SCRATCH_ALIGN } from './subworkflow/local/scratch_align.nf'
// include { SCRATCH_QC }    from './subworkflow/local/scratch_qc.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Check mandatory parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

if (params.samplesheet) { samplesheet = file(params.samplesheet) } else { exit 1, 'Please, provide a --input <PATH/TO/seurat_object.RDS> !' }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    log.info """\

        Parameters:

        Input: ${samplesheet}

    """

    // Description
    ch_samplesheet = Channel.fromPath(samplesheet, checkIfExists: true)

    // GEX+VDJ alignment
    SCRATCH_ALIGN(
        ch_samplesheet,
        params.modality,
        params.genome
    )

}

// workflow SCRATCH_QC_WORKFLOW {}
// workflow SCRATCH_CLUSTERING_WORKFLOW {}

workflow.onComplete {
    log.info(
        workflow.success ? "\nDone! Open the following report in your browser -> ${launchDir}/report/index.html\n" :
        "Oops... Something went wrong"
    )
}
