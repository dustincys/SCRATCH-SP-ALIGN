process SEURAT_NORMALIZE {
    tag "Running normalization and dimensionality reduction"
    label 'process_high'

    container "oandrefonseca/scratch-qc:main"

    input:
        path(seurat_object)
        path(notebook_normalize)
        path(page_config)

    output:
        path("data/${params.project_name}_reduction_object.RDS"), emit: project_rds
        path("report/${notebook_normalize.baseName}.html")

    when:
        task.ext.when == null || task.ext.when
        
    script:
        def param_file = task.ext.args ? "-P seurat_object:${seurat_object} -P ${task.ext.args}" : ""
        """
        quarto render ${notebook_normalize} ${param_file}
        """
    stub:
        """
        mkdir -p report data figures/reduction

        touch data/${params.project_name}_reduction_object.RDS
        touch report/${notebook_normalize.baseName}.html

        """
}
