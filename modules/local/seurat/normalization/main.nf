process SEURAT_NORMALIZE {
    tag "Running ${input_reduction_step} normalization"
    label 'process_high'

    container "oandrefonseca/scrpackages:main"

    input:
        path(seurat_object)
        path(notebook_normalize)

    output:
        path("${params.project_name}_reduction_object.RDS"), emit: project_rds
        path("report/${notebook_merge.baseName}.html")

    when:
        task.ext.when == null || task.ext.when
        
    script:
        def param_file = task.ext.args ? "-P input_qc_approved:${seurat_object} -P ${task.ext.args}" : ""
        """
        quarto render ${notebook_merge} ${param_file}

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${normalization_script}",
            params = list(
                project_name = "${params.project_name}",
                project_object = "${project_object}",
                input_reduction_step = "${input_reduction_step}",
                thr_n_features = ${params.thr_n_features},
                n_threads = ${task.cpus},
                n_memory = ${n_memory},
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_reduction_step}_reduction_object.html")
        """
    stub:
        """
        mkdir -p data figures/reduction

        touch data/${params.project_name}_${input_reduction_step}_reduction_object.RDS
        touch ${params.project_name}_${input_reduction_step}_reduction_object.html

        touch .dummy
        touch figures/reduction/EMPTY
        """
}
