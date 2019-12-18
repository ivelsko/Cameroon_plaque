################################################################################
# Projects: Coprolite evolution
# Part: Composition analysis
# Step: Custom RefSeq + Pasolli et al. SGBs database
#
# Kraken2 (Wood et al., 2019) and Bracken (Lu et al., 2017) provide
# pre-compiled MiniKraken RefSeq database, however, these are both outdated and
# lack newly assembled metagenomes from non-Westernised populations, e.g. from
# Pasolli et al. (2019). Therefore, I will create a custom database in order to
# obtain a higher assignment rate than what was observed for default database
# when using simulated data from Velsko et al. (2018).
#
# Alex velsko, 17/10/19
################################################################################

from glob import glob
import os.path
import re

import numpy as np
import pandas as pd
from ete3 import NCBITaxa

workdir: "/projects1/users/velsko/snakemake_tmp"

rule all:
    input: 

#### Build database ############################################################
# Add RefSeq
if os.path.isfile("/projects1/microbiome_sciences/reference_databases/refseq20191017_Pasolli2019/refseq_selected_genomes.txt.gz"):
    refseq_list = pd.read_csv("/projects1/microbiome_sciences/reference_databases/refseq20191017_Pasolli2019/refseq_selected_genomes.txt.gz",
                              sep="\t", index_col=[0])
    REFSEQGENOMEIDS = refseq_list.index.values
else:
    REFSEQGENOMEIDS = []

N_REFSEQ_BATCHES = REFSEQGENOMEIDS.shape[0] // 100 + 1

def select_fasta_sequences(ids, b, path, i=100):
    '''Select batch of 100 FastA sequences from RefSeq genomes.'''
    if (b + 1) * i > ids.shape[0]:
        subset = ids[(b * i):]
    else:
        subset = ids[(b * i):((b + 1) * i)]
    return [f"{path}/{id}/{id}_genomic.fna.gz" for id in subset]

rule build_kraken2_database:
    input:
       "/projects1/microbiome_sciences/reference_databases/refseq20191017/kraken2_db/RefSeq1910/hash.k2d" 

rule download_taxonomy:
    output:
        "/projects1/microbiome_sciences/reference_databases/refseq20191017/kraken2_db/RefSeq1910/taxonomy/nucl_wgs.accession2taxid"
    message: "Download taxonomy information from NCBI"
    params:
        dir = "/projects1/microbiome_sciences/reference_databases/refseq20191017/kraken2_db"
    shell:
        """
        cd {params.dir}
        kraken2-build --download-taxonomy --db RefSeq1910
        """

rule add_refseq:
    output:
        touch("/projects1/users/velsko/tmp/kraken2_addlib/batch_{i}.added")
    message: "Add RefSeq sequence batch {wildcards.i} to database"
    params:
        dir = "/projects1/microbiome_sciences/reference_databases/refseq20191017/kraken2_db",
        fasta = lambda wildcards: select_fasta_sequences(REFSEQGENOMEIDS, int(wildcards.i), '/projects1/microbiome_sciences/reference_databases/refseq20191017_Pasolli2019/refseq'),
        tmpfasta = "/projects1/users/velsko/tmp/kraken2_addlib"
    shell:
        """
        cd {params.dir}
        for fasta in {params.fasta}; do
            zcat ${{fasta}} > {params.tmpfasta}/$(basename ${{fasta}} .gz)
            kraken2-build --add-to-library {params.tmpfasta}/$(basename ${{fasta}} .gz) --db RefSeq1910
            rm {params.tmpfasta}/$(basename ${{fasta}} .gz)
        done
        """

rule kraken2_build_database:
    input:
        refseq = expand("/projects1/users/velsko/tmp/kraken2_addlib/batch_{i}.added", i=range(N_REFSEQ_BATCHES)),
        taxonomy = "/projects1/microbiome_sciences/reference_databases/refseq20191017/kraken2_db/RefSeq1910/taxonomy/nucl_wgs.accession2taxid"
    output:
        "/projects1/microbiome_sciences/reference_databases/refseq20191017/kraken2_db/RefSeq1910/hash.k2d"
    message: "Kraken2 build database"
    params:
        dir = "/projects1/microbiome_sciences/reference_databases/refseq20191017/kraken2_db",
    threads: 112
    shell:
        """
        cd {params.dir}
        kraken2-build --build \
                      --db RefSeq1910 \
                      --threads {threads}
        """

rule kraken2_minikraken2:
    input:
        "/projects1/microbiome_sciences/reference_databases/refseq20191017/kraken2_db/RefSeq1910/hash.k2d"
    output:
        "/projects1/microbiome_sciences/reference_databases/refseq20191017/kraken2_db/MiniKraken_RefSeq1910/hash.k2d"
    message: "Down-sample the full Kraken2 database to fit into 8GB of memory"
    params:
        dir = "/projects1/microbiome_sciences/reference_databases/refseq20191017/kraken2_db",
        fulldir = "/projects1/microbiome_sciences/reference_databases/refseq20191017/kraken2_db/RefSeq1910"
    threads: 112
    shell:
        """
        cd {params.dir}
        ln -s {params.fulldir}/library {params.dir}/MiniKraken_RefSeq1910
        ln -s {params.fulldir}/taxonomy {params.dir}/MiniKraken_RefSeq1910
        ln -s {params.fulldir}/unmapped.txt {params.dir}/MiniKraken_RefSeq1910
        kraken2-build --build \
                      --db MiniKraken_RefSeq1910 \
                      --max-db-size 8000000000 \
                      --threads {threads}
        """
