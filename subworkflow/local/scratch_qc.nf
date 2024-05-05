//
// Description
//

// include { SEURAT_QUALITY            } from '../../modules/local/seurat/quality/main.nf'
// include { HELPER_SUMMARIZE          } from '../../modules/local/helper/summarize/main.nf'
// include { SEURAT_MERGE              } from '../../modules/local/seurat/merge/main.nf'
// include { DOUBLETFINDER             } from '../../modules/local/doubletfinder/main.nf'
// include { SCDBLFINDER               } from '../../modules/local/doubletfinder/main.nf'

// Importing Quarto notebooks
merge_script     = "${workflow.projectDir}/modules/local/seurat/merge/notebook_seurat_merge.qmd"
doubletfinder    = "${workflow.projectDir}/modules/local/doubletfinder/notebook_doublet_detection.qmd"
scdblfinder      = "${workflow.projectDir}/modules/local/seurat/cluster/notebook_scdblfinder.qmd"

workflow SCRATCH_QC {

    take:
        ch_gex_outs // channel: [ val(meta), [ ... ] ]
        ch_meta_data    // channel

    main:

        ch_cell_matrices = ch_gex_outs
            .map{sample, files -> [sample, files.findAll{ it.toString().endsWith("metrics_summary.csv") || it.toString().endsWith("filtered_feature_bc_matrix") }]}
            .map{sample, files -> [sample, files[0], files[1]]}

        ch_cell_matrices = ch_cell_matrices
            .combine(ch_meta_data)

        // Performing QC steps
        SEURAT_QUALITY(
            ch_notebook_qc,
            ch_cell_matrices
        )

        // Writing QC check
        ch_quality_report = SEURAT_QUALITY.out.metrics
            .collect()

        // Generating QC table
        HELPER_SUMMARIZE(
            ch_notebook_summarize,
            ch_quality_report
        )

        // Filter poor quality samples
        ch_qc_approved = SEURAT_QUALITY.out.status
            .filter{sample, object, status -> status.toString().endsWith('SUCCESS.txt')}
            .map{sample, object, status -> object}
            .collect()

        ch_qc_approved
            .ifEmpty{error 'No samples matched QC expectations.'}
            .view{'Done'}

        // Merging all Seurat objects into a single-object
        SEURAT_MERGE(
            ch_qc_approved,
            merge_script
        )

        ch_merge_object = SEURAT_MERGE.out.project_rds

    emit:
        ch_merge_object
}