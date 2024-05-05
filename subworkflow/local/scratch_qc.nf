//
// Description
//

include { SEURAT_QUALITY       } from '../../modules/local/seurat/quality/main'
include { SEURAT_MERGE         } from '../../modules/local/seurat/merge/main'
include { SEURAT_CLUSTERING    } from '../../modules/local/seurat/clustering/main'

workflow SCRATCH_QC {

    take:
        ch_qc_approved // channel: [ val(meta), [ bam ] ]
        ch_meta_data    // channel

    main:

        ch_cell_matrices = ch_alignment.outs
            .map{sample, files -> [sample, files.findAll{ it.toString().endsWith("metrics_summary.csv") || it.toString().endsWith("filtered_feature_bc_matrix") }]}
            .map{sample, files -> [sample, files[0], files[1]]}

        ch_cell_matrices = ch_cell_matrices
            .combine(ch_meta_data)

        // Performing QC steps
        SCBTC_FILTERING(ch_cell_matrices, scqc_script)

        // Writing QC check
        ch_quality_report = SCBTC_FILTERING.out.metrics
            .collect()

        // Generating QC table
        SCBTC_QCRENDER(ch_quality_report, qc_table_script)

        // Filter poor quality samples
        ch_qc_approved = SCBTC_FILTERING.out.status
            .filter{sample, object, status -> status.toString().endsWith('SUCCESS.txt')}
            .map{sample, object, status -> object}
            .collect()

        ch_qc_approved
            .ifEmpty{error 'No samples matched QC expectations.'}
            .view{'Done'}


        // Rmarkdown scripts 
        merge_script   = "${workflow.projectDir}/notebook/notebook_merge.Rmd"
        cluster_script = "${workflow.projectDir}/notebook/notebook_cell_clustering.Rmd"

        // Description
        SCBTC_MERGE(
            ch_qc_approved,
            merge_script
        )

        ch_normalize = SCBTC_MERGE.out.project_rds

        // Description        
        SCBTC_CLUSTERING(          
            ch_normalize,
            SCBTC_MERGE.out.dummy,
            cluster_script,
            input_cluster_step
        )

        ch_cluster = SCBTC_CLUSTERING.out.project_rds      

    emit:
        ch_cluster
}