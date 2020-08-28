#!/usr/bin/env bash

sbatch \
-c 4 \
--mem=32000 \
--partition=short \
-o ~/slurm_logs/slurm.%j.out \
-e ~/slurm_logs/slurm.%j.err \
--mail-type=fail \
--mail-type=time_limit \
--mail-user=velsko@shh.mpg.de \
--wrap="songbird multinomial \
	--input-biom /projects1/microbiome_calculus/Cameroon_plaque/05-results.backup/malt_species_decontam.biom \
	--metadata-file /projects1/microbiome_calculus/Cameroon_plaque/00-documentation.backup/01-cameroon_hunter_gatherer_metadata.tsv \
	--formula "C(Env,Treatment('HunterGatherer'))" \
	--epochs 10000 \
	--differential-prior 0.5 \
	--summary-interval 1 \
	--summary-dir /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/songbird/species_noblanks/formTest"
