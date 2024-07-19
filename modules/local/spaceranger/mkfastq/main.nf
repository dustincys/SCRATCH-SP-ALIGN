process SPCERANGER_MKFASTQ {
    tag "$gtf"
    label 'process_low'

    container "dustincys/spaceranger:3.0.1"

    publishDir "${params.outdir}/${params.project_name}/data/fastq", mode: 'move'

    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        exit 1, "SPCERANGER_MKFASTQ module does not support Conda. Please use Docker / Singularity / Podman instead."
    }

    input:
        tuple val(id), path(run), path(csv)

    output:
        tuple val(id), path("${id}/outs/*"), emit: outs

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        """
        spaceranger \\
            mkfastq \\
            --id=${id} \\
            --run=${run} \\
            --csv=${csv} \\
            // --output-dir=${outs} \\
            $args
        """
}
