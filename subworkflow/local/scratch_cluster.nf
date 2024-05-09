//
// Description
//

include { SEURAT_NORMALIZE          } from '../../modules/local/seurat/normalization/main.nf'
// include { SEURAT_CLUSTER            } from '../../modules/local/seurat/cluster/main.nf'

// Importing Quarto notebooks
normalize_script = "${workflow.projectDir}/modules/local/seurat/normalize/notebook_seurat_normalize.qmd"
cluster_script   = "${workflow.projectDir}/modules/local/seurat/cluster/notebook_seurat_clustering.qmd"

workflow SCRATCH_CLUSTERING {

    // Channel definitions
    ch_versions  = Channel.empty()

    take:
        ch_merge_object // channel: [ val(meta), [ ... ] ]

    main:

        // Importing notebook
        ch_notebook_normalize   = Channel.fromPath(params.notebook_normalize, checkIfExists: true)

        // Description
        ch_template    = Channel.fromPath(params.template, checkIfExists: true)
            .collect()

        ch_page_config = Channel.fromPath(params.page_config, checkIfExists: true)
            .collect()

        SEURAT_NORMALIZE(
            ch_merge_object,
            ch_notebook_normalize,
            ch_page_config
        )

        // Performing clustering        
        // SEURAT_CLUSTER(          
        //     ch_merge_object,
        //     SEURAT_MERGE.out.dummy,
        //     cluster_script,
        //     input_cluster_step
        // )

        // ch_cluster = SEURAT_CLUSTER.out.project_rds

    emit:
        ch_versions
}

