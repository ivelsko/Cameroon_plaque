################################################################################
# Run HUMAnN3 on CMC data with all sequencing data (4M+10M+1M)
#
# Irina Velsko, 14/12/2021
################################################################################

from glob import glob
import os
import re

workdir: "/mnt/archgen/microbiome_calculus/Cameroon_plaque/04-analysis/humann2/all_data_combined"

#### SAMPLES ###################################################################
SAMPLES = {}
for sample in glob("/mnt/archgen/microbiome_calculus/Cameroon_plaque/04-analysis/humann2/all_data_combined/input/*.gz"):
	SAMPLES[os.path.basename(sample).split(".u")[0]] = sample
################################################################################

if not os.path.isdir("snakemake_tmp"):
    os.makedirs(f"{os.getcwd()}/snakemake_tmp")


rule all:
    input: 
        expand("output/{sample}.unmapped_genefamilies.tsv", sample=SAMPLES.keys())
#         "output/genefamilies_joined.tsv",
#         "output/genefamilies_joined_cpm.tsv",
#         "output/genefamilies_joined_cpm_ur90rxn.tsv",
#         "output/genefamilies_joined_cpm_ur90rxn_names.tsv",
#         "output/genefamilies_joined_cpm_ko.tsv",
#         "output/genefamilies_joined_cpm_ko_names.tsv",
#         "output/pathabundance_joined.tsv",
#         "output/pathabundance_joined_cpm.tsv"       


rule humann2:
    output:
        "output/{sample}.unmapped_genefamilies.tsv"
    message: "Run humann3 on {wildcards.sample}"
    params: 
        fastq = lambda wildcards: SAMPLES[wildcards.sample]
    threads: 16
    shell:
        """
        set +u
        source $HOME/miniconda3/etc/profile.d/conda.sh
        conda activate humann3
        set -u
        
        humann3 --input {params.fastq} --output output --threads {threads}
        """

# rule join_gf:
#     input:
#         "output/"
#     output:
#         "output/genefamilies_joined.tsv"
#     message: "Run humann3 join on gene families"
#     params:
#         infolder = "output/"
#     shell:
#         """
#         set +u
#         source $HOME/miniconda3/etc/profile.d/conda.sh
#         conda activate humann3
#         set -u
#         
#         humann_join_tables -i {params.infolder} -o {output} --file_name unmapped_genefamilies
#        """
# 
# rule renorm_gf:
#     input:
#         "output/genefamilies_joined.tsv"
#     output:
#         "output/genefamilies_joined_cpm.tsv"
#     message: "Run humann3 renorm on gene families"
#     params: 
#     shell:
#         """
#         set +u
#         source $HOME/miniconda3/etc/profile.d/conda.sh
#         conda activate humann3
#         set -u
#         
#         humann_renorm_table --input {input} --output {output} --units cpm
#        """
# 
# rule regroup_gf_ur90:
#     input:
#         "output/genefamilies_joined_cpm.tsv"
#     output:
#         "output/genefamilies_joined_cpm_ur90rxn.tsv"
#     message: "Run humann3 regroup on gene families for UR90"
#     params: 
#     shell:
#         """
#         set +u
#         source $HOME/miniconda3/etc/profile.d/conda.sh
#         conda activate humann3
#         set -u
#         
#         humann_regroup_table --input {input} --output {output} --groups uniref90_rxn
#        """
# 
# rule rename_gf_ur90:
#     input:
#         "output/genefamilies_joined_cpm_ur90rxn.tsv"
#     output:
#         "output/genefamilies_joined_cpm_ur90rxn_names.tsv"
#     message: "Run humann3 rename on gene families for UR90"
#     params: 
#     shell:
#         """
#         set +u
#         source $HOME/miniconda3/etc/profile.d/conda.sh
#         conda activate humann3
#         set -u
#         
#         humann_rename_table --input {input} --output {output} -n uniref90
#        """
# 
# 
# rule regroup_gf_kegg:
#     input:
#         "output/genefamilies_joined_cpm.tsv"
#     output:
#         "output/genefamilies_joined_cpm_ko.tsv"
#     message: "Run humann3 regroup on gene families for KO"
#     params: 
#     shell:
#         """
#         set +u
#         source $HOME/miniconda3/etc/profile.d/conda.sh
#         conda activate humann3
#         set -u
#         
#         humann_regroup_table --input {input} --output {output} --groups uniref90_ko
#        """
# 
# rule rename_gf_ko:
#     input:
#         "output/genefamilies_joined_cpm_ko.tsv"
#     output:
#         "output/genefamilies_joined_cpm_ko_names.tsv"
#     message: "Run humann3 rename on gene families for KO"
#     params: 
#     shell:
#         """
#         set +u
#         source $HOME/miniconda3/etc/profile.d/conda.sh
#         conda activate humann3
#         set -u
#         
#         humann_rename_table --input {input} --output {output} -n kegg-orthology
#        """
# 
# rule join_pa:
#     input:
#         "output/"
#     output:
#         "output/pathabundance_joined.tsv"
#     message: "Run humann3 join on path abundance"
#     shell:
#         """
#         set +u
#         source $HOME/miniconda3/etc/profile.d/conda.sh
#         conda activate humann3
#         set -u
#         
#         humann_join_tables -i {input} -o {output} --file_name unmapped_pathabundance
#        """
# 
# rule renorm_pa:
#     input:
#         "output/pathabundance_joined.tsv"
#     output:
#         "output/pathabundance_joined_cpm.tsv"
#     message: "Run humann3 renorm on gene families"
#     params: 
#     shell:
#         """
#         set +u
#         source $HOME/miniconda3/etc/profile.d/conda.sh
#         conda activate humann3
#         set -u
#         
#         humann_renorm_table --input {input} --output {output} --units cpm
#        """
# 
