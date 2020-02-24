#!/bin/bash

sbatch \
-c 112 \
--mem 1900G \
--partition=supercruncher \
-o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.bl2rma.out \
-e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.bl2rma.err \
--mail-type=fail \
--mail-type=time_limit \
--mail-user=velsko@shh.mpg.de \
-J "blast2rma" \
--wrap="/projects1/users/velsko/bin/megan_6_13/tools/blast2rma \
--format SAM \
-i /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/output/Nov2018acc/*out.gz \
-o /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/rma6_kegg/ \
-a2kegg /projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/megan_mapping_files/acc2kegg-Jul2019X.abin \
-a2t /projects1/malt/databases/acc2tax/nucl_acc2tax-Nov2018.abin \
-v"

#--wrap="/projects1/users/fellows/bin.backup/megan6/tools/blast2rma \
#--format SAM \
#-i /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/output/*out.gz \
#-o /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/rma6/ \
#-a2seed /projects1/malt/databases/acc2seed/acc2seed-May2015XX.abin \
#-a2t /projects1/malt/databases/acc2tax/nucl_acc2tax-Nov2018.abin \
#-v"

#--wrap="/projects1/users/velsko/bin/megan/tools/blast2rma \
#--format SAM \
#-i /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/output/*out.gz \
#-o /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/rma6_kegg/ \
#-a2seed /projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/megan_mapping_files/megan-map-Oct2019.db \
#-a2t /projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/megan_mapping_files/megan-map-Oct2019.db \
#-v"
