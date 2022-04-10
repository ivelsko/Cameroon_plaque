################################################################################
# Recover the original HMP plaque data run through Kraken2 from the old output files
#
# Irina Velsko 10/04/2021
################################################################################

from glob import glob
import os
import re

workdir: "/mnt/archgen/microbiome_calculus/Cameroon_plaque/04-analysis/kraken/output/RefSeqOnly"

#### SAMPLES ###################################################################
SAMPLES = {}
for sample in glob("/mnt/archgen/microbiome_calculus/Cameroon_plaque/04-analysis/kraken/output/RefSeqOnly/SRR*.rso.kraken"):
	SAMPLES[os.path.basename(sample).split("_")[0]] = sample
################################################################################

if not os.path.isdir("snakemake_tmp"):
    os.makedirs(f"{os.getcwd()}/snakemake_tmp")


rule all:
    input: 
        expand("{sample}.report.rs.kraken", sample=SAMPLES.keys()),
        expand("{sample}.report_mpa.rs.kraken", sample=SAMPLES.keys())

rule kraken_rs_report:
    output:
        "{sample}.report.rs.kraken"
    message: "Convert output file of {wildcards.sample} to standard report format"
    params: 
        taxonomy = "",
        infile = lambda wildcards: SAMPLES[wildcards.sample],
    shell:
        """
        /mnt/archgen/users/velsko/bin/krakenTools/make_kreport.py \
        --input {params.infile}\
        --taxonomy /mnt/archgen/microbiome_calculus/Cameroon_plaque/04-analysis/kraken/output/RefSeqOnly/ktaxonomy_rs.out \
        --output {output}
        """

rule kraken_rs_mpa:
    input:"{sample}.report.rs.kraken"
    output:
        "{sample}.report_mpa.rs.kraken"
    message: "Convert report format of {wildcards.sample} to mpa format"
    params: 
        taxonomy = "",
        infile = lambda wildcards: SAMPLES[wildcards.sample],
    shell:
        """
        /mnt/archgen/users/velsko/bin/krakenTools/kreport2mpa.py \
        --report {input} \
        --output {output} \
        --display-header 
        """
