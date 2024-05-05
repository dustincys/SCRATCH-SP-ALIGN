SEURAT_MERGE {
    tag "${sample}"
    label 'process_high'

    container "oandrefonseca/scaligners:main"
    publishDir "${params.outdir}/${params.project_name}/data/sample", mode: 'copy'

    input:
        tuple val(sample), path(reads)
        path  reference

    output:
        tuple val(sample), path("${sample}/outs/*"), emit: outs
        path("versions.yml")                       , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        """
        """

    stub:
        """
        """
}