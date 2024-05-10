process SEURAT_MERGE {

    tag "Merging post-QC samples"
    label 'process_high'

    container "oandrefonseca/scratch-cluster:main"

    input:
        path(ch_qc_approved)
        path(notebook_merge)
        path(ch_exp_table)
        path(ch_page_config)

    output:
        path("data/${params.project_name}_merged_object.RDS"), emit: project_rds
        path("report/${notebook_merge.baseName}.html")

    when:
        task.ext.when == null || task.ext.when
        
    script:
        def param_file = task.ext.args ? "-P input_qc_approved:\'${ch_qc_approved.join(';')}\' -P input_exp_table:${ch_exp_table} -P ${task.ext.args}" : ""
        """
        quarto render ${notebook_merge} ${param_file}
        """
    stub:
        def param_file = task.ext.args ? "-P input_qc_approved:\'${ch_qc_approved.join(';')}\' -P input_exp_table:${ch_exp_table} -P ${task.ext.args}" : ""
        """
        mkdir -p report data figures/merge

        touch ${params.project_name}_merged_object.RDS
        touch report/${notebook_merge.baseName}.html

        """
}
