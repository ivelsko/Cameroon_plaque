#!/bin/bash

sbatch \
-c 112 \
--mem 1900G \
--partition=supercruncher \
-o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.aadder.out \
-e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.aadder.err \
--mail-type=fail \
--mail-type=time_limit \
--mail-user=velskos@shh.mpg.de \
-J "aadderCMC" \
--wrap="/projects1/users/fellows/bin.backup/megan6/tools/aadder-run \
-i /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/input-temp/*.sam.gz \
-d /projects1/microbiome_calculus/evolution/01-data/databases/aadder/ \
-o /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/output/ \
-v
pigz -p 112 /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/aadder/output/*"

