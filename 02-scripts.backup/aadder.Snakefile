################################################################################
# Projects: Cameroon non-industrial population plaque
# Part: Functional classification
# Step: AADDER with new MEGAN scripts and databases
#
# Add some kind of introduction here
# 
# Irina Velsko, ADDADATE
################################################################################

from glob import glob
import os.path
import re

workdir: "/projects1/users/velsko/cmc/snakemake_tmp"

#### SAMPLES ###################################################################
SAMPLES = {}
for fn in glob("/projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/input-temp/*.sam.gz"): 
    sample = re.sub("_.+$", "" , ".".join(os.path.basename(fn).split(".")[:2]))
    if "10M" in fn:
         sample += "_10M"
    SAMPLES[sample] = fn
################################################################################

rule all:
    input:
    	expand("/projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/rma6/July2019KEGG/{sample}.rma6", sample=SAMPLES.keys())
#    	expand("/projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/rma6/July2019KEGG/{sample}.rma6", sample=['LIB050.A0107'])



#### Build AADDER database w/ new accession files

rule build_aadder_db:
    output:
        outdb = "/projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/aadder/Oct2019/aadd.dbx",
        outid = "/projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/aadder/Oct2019/aadd.idx"
    message: "Build AADDER database with most recent file"
    params:
        gffpath = "/projects1/microbiome_sciences/reference_databases/refseq/genomes/bacteria_archea_homo_20181122/raw",
        acc2tax = "/projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/megan_mapping_files/megan-nucl-Oct2019.db",
        outdir = "/projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/aadder/Oct2019/"
    benchmark: "/projects1/users/velsko/cmc/snakemake_tmp/build_aadder_db.log"
    threads: 112
    shell:
        """
        /projects1/users/velsko/bin/megan/tools/aadder-build \
        -igff {params.gffpath} \
        -d  {params.outdir} \
        -a2t {params.acc2tax} \
        -ex \
        -v
        """

#### Run AADDER 

rule run_aadder:
    input:
        outdb = "/projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/aadder/Oct2019/aadd.dbx",
        outid = "/projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/aadder/Oct2019/aadd.idx"
    output:
        "/projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/output/{sample}.out.gz"
    message: "Run AADDER: {wildcards.sample}"
    params:
        dbdir = "/projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/aadder/Oct2019",
        sam = lambda wildcards: SAMPLES[wildcards.sample],
        outdir = "/projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/output/Oct2019db/{sample}"
    benchmark: "/projects1/users/velsko/cmc/snakemake_tmp/{sample}.run_adder.log"
    threads: 112
    shell:
        """
        /projects1/users/velsko/bin/megan/tools/aadder-run \
        -i {params.sam} \
        -d {params.dbdir} \
        -o {params.outdir} \
        -v
        pigz -p 112 {params.outdir}/*.out
        """

#### Convert AADDER out.gz to .rma6 for KEGG classification ####################
# this may need to be run with the old script (in James' folder) for KEGG 
# classification. The SEED classification (next section) should be done with 
# these new scripts and the new MEGAN database

rule blast_2_rma6_kegg:
    input:
        "/projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/output/{sample}.out.gz"
    output:
        "/projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/rma6/July2019KEGG/{sample}.rma6"
    message: "Convert AADDER .out files to .rma6: {wildcards.sample}"
    params:
        dir = "",
        acc2kegg = "/projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/megan_mapping_files/acc2kegg-Jul2019X-ue.abin",
        acc2tax = "/projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/megan_mapping_files/megan-nucl-Oct2019.db",
        outdir = "/projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/rma6/July2019KEGG"
    benchmark: "/projects1/users/velsko/cmc/snakemake_tmp/{sample}.blast_2_rma6_kegg.log"
    threads: 112
    shell:
        """
        /projects1/users/velsko/bin/megan/tools/blast2rma \
        --format SAM \
        -i {input} \
        -o {params.outdir} \
        -a2kegg {params.acc2kegg} \
        -a2t {params.acc2tax} \
        -v
        mv {params.outdir}/{wildcards.sample}.out.gz.rma6 {output}
        """

#### Convert AADDER out.gz to .rma6 for SEED classification ####################
#  The SEED classification should be done with these new
# scripts and the new MEGAN database

for fn in glob("/projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/output/Oct2019db/*.out.gz"):
    sample = os.path.basename(fn)
    SAMPLES[sample] = fn
    

rule blast_2_rma6_seed:
    input:
        "/projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/output/Oct2019db/*.out.gz"
    output:
        "/projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/rma6/July2019KEGG"
    message: "Convert AADDER .out files to .rma6"
    params:
        dir = ""
    shell:
        """
        /projects1/users/velsko/bin/megan/tools/blast2rma \
        --format SAM \
        -i /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/output/Oct2019db/*out.gz \
        -o /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/rma6/July2019KEGG \
        # -a2seed /projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/megan_mapping_files/megan-map-Oct2019.db \
        -a2kegg /projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/megan_mapping_files/acc2kegg-Jul2019X-ue.abin \
        -a2t /projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/megan_mapping_files/megan-nucl-Oct2019.db \
        -v
        """
