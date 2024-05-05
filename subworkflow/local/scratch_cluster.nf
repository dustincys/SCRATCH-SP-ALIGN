//
// Description
//

// include { SEURAT_CLUSTER            } from '../../modules/local/seurat/cluster/main.nf'
// include { SEURAT_NORMALIZE          } from '../../modules/local/seurat/cluster/main.nf'

// Importing Quarto notebooks
normalize_script = "${workflow.projectDir}/modules/local/seurat/normalize/notebook_seurat_normalize.qmd"
cluster_script   = "${workflow.projectDir}/modules/local/seurat/cluster/notebook_seurat_clustering.qmd"

workflow SCRATCH_CLUSTERING {

    take:
        ch_merge_object // channel: [ val(meta), [ ... ] ]

    main:

        // Performing clustering        
        SEURAT_CLUSTER(          
            ch_merge_object,
            SEURAT_MERGE.out.dummy,
            cluster_script,
            input_cluster_step
        )

        ch_cluster = SEURAT_CLUSTER.out.project_rds

    emit:
        ch_cluster
}

