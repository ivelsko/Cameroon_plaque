#!/usr/bin/env bash
sbatch \
-c 112 \
--mem 1850000 \
--partition=supercruncher \
-o ~/slurm_logs/slurm.%j.out \
-e ~/slurm_logs/slurm.%j.err \
--mail-type=fail \
--mail-type=time_limit \
--mail-user=velsko@shh.mpg.de \
-J "cmc_assembly" \
--wrap="nextflow run nf-core/mag \
--reads '/projects1/microbiome_calculus/Cameroon_plaque/04-analysis/assembly/input/*.R{1,2}.fastq.gz' \
-profile shh \
--kraken2_db /projects1/microbiome_sciences/reference_databases/refseq20191017_Pasolli2019/kraken2_db/MiniKraken_RefSeq1910PlusPasolliSGBs  \
--outdir /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/assembly/output \
-name cmc_assembly"

