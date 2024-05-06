#!/usr/bin/env python3

from cirro.helpers.preprocess_dataset import PreprocessDataset
import pandas as pd
import os

def adding_modality(ds: PreprocessDataset) -> pd.DataFrame):
    
    # Make a wide sample_table
    ds.logger.info("Adding modality column from:")

    # Can I check if has modality column?
    sample_table = ds.wide_samplesheet(
        index=["sampleIndex", "sample", "lane"],
        columns="read",
        values="file",
        column_prefix="fastq_"
    ).sort_values(
        by="sample"
    )

    # How can I read the metadata? Is it ds.samplesheet?
    # sample_table = sample_table.merge(ds.samplesheet)
    # return sample_table

if __name__ == "__main__":

    ds = PreprocessDataset.from_running()

    ds.logger.info("Files annotated in the dataset:")
    ds.logger.info(ds.files)

    ds.logger.info("Checking medata:")
    ds.logger.info(ds.ds.samplesheet)

    ds.logger.info("Exported paths:")
    ds.logger.info(os.environ['PATH'])

    ds.logger.info("Printing out parameters:")
    ds.logger.info(ds.params)