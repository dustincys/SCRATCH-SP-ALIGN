
process CELLBENDER {

    tag "Running Cellbender on ${sample}"
    label 'process_high'

    container "us.gcr.io/broad-dsde-methods/cellbender:0.3.0"

    input:
        path(matrix_h5ad)

    output:
        path(filtered_h5file)

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ? : ''
        """
        cellbender remove-background \
            --input ${matrix_h5ad} \
            --output ${filtered_h5file} \
            --expected-cells ${expected_cells} \
            --total-droplets-included ${total_droplets}
        """

}