//
// Description
//

include { SEURAT_QUALITY            } from '../../modules/local/seurat/quality/main.nf'
include { HELPER_SUMMARIZE          } from '../../modules/local/helper/summarize/main.nf'
include { SEURAT_MERGE              } from '../../modules/local/seurat/merge/main.nf'

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
        ch_notebook_summarize     = Channel.fromPath(params.notebook_summarize, checkIfExists: true)
        ch_notebook_merge         = Channel.fromPath(params.notebook_merge, checkIfExists: true)
        ch_notebook_doubletfinder = Channel.fromPath(params.notebook_doubletfinder, checkIfExists: true)
        ch_notebook_scdblfinder   = Channel.fromPath(params.notebook_scdblfinder, checkIfExists: true)

        // Description
        ch_template    = Channel.fromPath(params.template, checkIfExists: true)
            .collect()

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

        // Ensuring file order
        ch_cell_matrices = ch_cell_matrices
            .map{ sample, files -> 
                def csvFile = files.find { it.toString().endsWith("metrics_summary.csv") }
                def h5File = files.find { it.toString().endsWith("filtered_feature_bc_matrix.h5") }
                [sample, csvFile, h5File]
            }

        ch_cell_matrices
            .view()

        SEURAT_QUALITY(
            ch_cell_matrices,
            ch_notebook_quality.collect(),
            ch_page_config
        )

        // Writing QC check
        ch_quality_report = SEURAT_QUALITY.out.metrics
            .collect()
        
        ch_quality_report
            .view()

        // Generating QC table
        HELPER_SUMMARIZE(
            ch_quality_report,
            ch_notebook_summarize,
            ch_page_config
        )

        // // Filter poor quality samples
        ch_qc_approved = SEURAT_QUALITY.out.status
            .filter{sample, object, status -> status.toString().endsWith('SUCCESS.txt')}
            .map{sample, object, status -> object}
            .collect()

        ch_qc_approved
            .view()

        ch_qc_approved
            .ifEmpty{error 'No samples matched QC expectations.'}
            .view{'Done'}

        // // Merging all Seurat objects into a single-object
        SEURAT_MERGE(
            ch_qc_approved,
            ch_notebook_merge,
            ch_exp_table,
            ch_page_config
        )

        ch_merge_object = SEURAT_MERGE.out.project_rds

    emit:
        ch_merge_object
}