#!/usr/bin/env python3

from cirro.helpers.preprocess_dataset import PreprocessDataset
import pandas as pd
import os

def adding_modality():
    pass

def setup_input_parameters(ds: PreprocessDataset):
    # If the user did not select a custom malignant table, use the default
    pass

if __name__ == "__main__":

    ds = PreprocessDataset.from_running()
    setup_input_parameters(ds)

    ds.logger.info("Files annotated in the dataset:")
    ds.logger.info(ds.files)

    ds.logger.info("Printing metadata related to dataset:")
    ds.logger.info(ds.samplesheet)

    # Make a wide sample_table
    ds.logger.info("Pivoting to wide format:")
    sample_table = ds.wide_samplesheet(
        index=["sampleIndex", "sample", "lane"],
        columns="read",
        values="file",
        column_prefix="fastq_"
    ).sort_values(
        by="sample"
    )
    ds.logger.info(sample_table.to_csv(index=None))

    ds.logger.info("Exported paths:")
    ds.logger.info(os.environ['PATH'])

    ds.logger.info("Printing out parameters:")
    ds.logger.info(ds.params)