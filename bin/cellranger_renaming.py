#!/usr/local/bin/python3

import os
import sys
import re

def is_already_10x_format(sample_name, filename):
    """
    Checks if the filename is already in the 10x naming format:
    {sample_name}_S1_L001_R{1,2}_001.fastq.gz
    """
    pattern = re.compile(rf'^{re.escape(sample_name)}_S1_L001_R[12]_001\.fastq\.gz$')
    return pattern.match(filename)

def rename_fastqs(sample_name, fastq_dir):
    """
    Renames FASTQ files in the specified directory based on the sample name provided.
    Assumes files are named as SRX..._SRR..._{1,2}.fastq.gz and renames them to
    {sample_name}_S1_L001_R{1,2}_001.fastq.gz format.
    """
    # Iterate over all files in the directory
    for filename in os.listdir(fastq_dir):
        if filename.endswith(".fastq.gz"):
            if not is_already_10x_format(sample_name, filename):
                # Splitting the filename to extract parts
                parts = filename.split('_')

                # Extract pair number from the part before the ".fastq.gz"
                part_before_extension = parts[-1].split('.')[0]
                pair_number = part_before_extension[-1]

                # Creating string based on 10x format
                new_filename = f"{sample_name}_S1_L001_R{pair_number}_001.fastq.gz"

                # Renaming the file
                old_path = os.path.join(fastq_dir, filename)
                new_path = os.path.join(fastq_dir, new_filename)
                os.rename(old_path, new_path)

if __name__ == "__main__":
    sample_name, fastq_dir = sys.argv[1], sys.argv[2]
    rename_fastqs(sample_name, fastq_dir)
