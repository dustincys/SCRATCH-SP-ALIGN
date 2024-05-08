//
// Description
//

include { SEURAT_QUALITY            } from '../../modules/local/seurat/quality/main.nf'
// include { HELPER_SUMMARIZE          } from '../../modules/local/helper/summarize/main.nf'
// include { SEURAT_MERGE              } from '../../modules/local/seurat/merge/main.nf'
// include { DOUBLETFINDER             } from '../../modules/local/doubletfinder/main.nf'
// include { SCDBLFINDER               } from '../../modules/local/doubletfinder/main.nf'

workflow SCRATCH_QC {

    take:
        ch_gex_matrices // channel: [ val(meta), [ ... ] ]
        ch_exp_table    // channel

    main:
        
        // Channel definitions
        ch_versions  = Channel.empty()

        // Importing notebook
        ch_notebook_quality       = Channel.fromPath(params.notebook_quality, checkIfExists: true)
        ch_notebook_merge         = Channel.fromPath(params.notebook_merge, checkIfExists: true)
        ch_notebook_doubletfinder = Channel.fromPath(params.notebook_doubletfinder, checkIfExists: true)
        ch_notebook_scdblfinder   = Channel.fromPath(params.notebook_scdblfinder, checkIfExists: true)

        // Description
        ch_template    = Channel.fromPath(params.template, checkIfExists: true)
        ch_page_config = Channel.fromPath(params.page_config, checkIfExists: true)
            .collect()

        // Grouping cellranger outputs
        ch_cell_matrices = ch_gex_matrices
            .map { file -> 
                def sample = file.parent.parent.name
                return [sample, file]
            }
        
        ch_cell_matrices = ch_cell_matrices
            .groupTuple()

        ch_cell_matrices = ch_cell_matrices
            .map{ sample, files -> [sample, files.findAll{ it.toString().endsWith("metrics_summary.csv") || it.toString().endsWith("filtered_feature_bc_matrix.h5") }] }
            .map{ sample, files -> [sample, files[0], files[1]]}

        ch_cell_matrices
            .view()

        SEURAT_QUALITY(
            ch_cell_matrices,
            ch_notebook_quality,
            ch_page_config
        )

        // Writing QC check
        // ch_quality_report = SEURAT_QUALITY.out.metrics
        //     .collect()

        // // Generating QC table
        // HELPER_SUMMARIZE(
        //     ch_notebook_summarize,
        //     ch_quality_report
        // )

        // // Filter poor quality samples
        // ch_qc_approved = SEURAT_QUALITY.out.status
        //     .filter{sample, object, status -> status.toString().endsWith('SUCCESS.txt')}
        //     .map{sample, object, status -> object}
        //     .collect()

        // ch_qc_approved
        //     .ifEmpty{error 'No samples matched QC expectations.'}
        //     .view{'Done'}

        // // Merging all Seurat objects into a single-object
        // SEURAT_MERGE(
        //     ch_qc_approved,
        //     merge_script
        // )

        // ch_merge_object = SEURAT_MERGE.out.project_rds

    emit:
        ch_versions //ch_merge_object
}