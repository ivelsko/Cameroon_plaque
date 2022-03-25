################################################################################
# Run Kraken2 on all_data_combined CMC + additional samples
#
# Irina Velsko, 06/12/2021
################################################################################

from glob import glob
import os
import re

workdir: "/mnt/archgen/microbiome_calculus/Cameroon_plaque/04-analysis/kraken/all_data_combined/"

#### SAMPLES ###################################################################
SAMPLES = {}
for sample in glob("/mnt/archgen/microbiome_calculus/Cameroon_plaque/04-analysis/kraken/all_data_combined/input/*.gz"):
	SAMPLES[os.path.basename(sample).split(".u")[0]] = sample
################################################################################

if not os.path.isdir("snakemake_tmp"):
    os.makedirs(f"{os.getcwd()}/snakemake_tmp")


rule all:
    input: 
        "databases/bact_arch_06122021/hash.k2d"
#        expand("output/{sample}.report", sample=SAMPLES.keys())

rule kraken_db:
    output:
        "databases/bact_arch_06122021/hash.k2d"
    message: "Build kraken2 database w/bacteria, archaea, humnan"
    params: 
    threads: 32
    shell:
        """
        set +u
        source $HOME/miniconda3/etc/profile.d/conda.sh
        conda activate kraken2
        set -u

        kraken2-build --build --db databases/bact_arch_06122021 --threads 32
        """

rule kraken_classify:
    output:
        "output/{sample}.report"
    message: "Run CMC deep sequence data through kraken2 database w/bacteria, archaea, humnan"
    params: 
        database = "",
        report = "",
        outfile = ""
    threads: 32
    shell:
        """
        set +u
        source $HOME/miniconda3/etc/profile.d/conda.sh
        conda activate kraken2
        set -u

        kraken2 --db $DBNAME \
        seqs.fa \
        --threads 32 \
        --output <filename> \
        --report <filename> \
        --report-zero-counts \
        --use-mpa-style \
        --use-names  \
        --gzip-compressed
        """
