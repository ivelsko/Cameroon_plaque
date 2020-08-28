#!/bin/bash

#SBATCH -n 4
#SBATCH --mem 24G
#SBATCH --partition=short
#SBATCH -o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.out
#SBATCH -e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.err
#SBATCH --mail-type=fail
#SBATCH --mail-type=time_limit
#SBATCH --mail-use=velsko@shh.mpg.de
#SBATCH -J "songbird"

songbird multinomial \
	        --input-biom /projects1/microbiome_calculus/Cameroon_plaque/05-results.backup/malt_species_cmc_decontam.biom \
	        --metadata-file /projects1/microbiome_calculus/Cameroon_plaque/00-documentation.backup/01-cameroon_hunter_gatherer_metadata.tsv \
		--formula "C(Sex, Treatment('Male'))" \
	        --epochs 10000 \
	        --differential-prior 0.5 \
	        --summary-interval 1 \
	        --summary-dir /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/songbird/species_cmc/form4

