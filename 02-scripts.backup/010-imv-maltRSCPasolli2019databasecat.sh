#!/usr/bin/env bash
sbatch \
-c 2 \
--mem 4G \
--partition=short \
-o ~/slurm_logs/slurm.%j.out \
-e ~/slurm_logs/slurm.%j.err \
--mail-type=fail \
--mail-user=velsko@shh.mpg.de \
-J "catmalt" \
--wrap="cat /projects1/microbiome_sciences/reference_databases/refseq/genomes/bacteria_archea_homo_20181122/refseq_genomes_bacteria_archaea_homo_complete_chromosome_scaffold_20181122.fna.gz /projects1/microbiome_sciences/reference_databases/Pasolli2019_MAGs/representatives/oral_nonwest/Pasolli2019MAGs.fasta.gz > /projects1/microbiome_sciences/reference_databases/refseq_Pasolli2019MAGS/refseq_genomes_bacteria_archaea_homo_complete_chromosome_scaffold_Pasolli2019MAGs_20191015.fna.gz"

#--wrap="zcat /projects1/microbiome_sciences/reference_databases/refseq/genomes/bacteria_archea_homo_20181122/refseq_genomes_bacteria_archaea_homo_complete_chromosome_scaffold_20181122.fna.gz | cat - /projects1/microbiome_sciences/reference_databases/Pasolli2019_MAGs/representatives/oral_nonwest/Pasolli2019MAGs.fasta > /projects1/microbiome_sciences/reference_databases/refseq_Pasolli2019MAGS/refseq_genomes_bacteria_archaea_homo_complete_chromosome_scaffold_Pasolli2019MAGs_20190930.fna && pigz -n2 /projects1/microbiome_sciences/reference_databases/refseq_Pasolli2019MAGS/refseq_genomes_bacteria_archaea_homo_complete_chromosome_scaffold_Pasolli2019MAGs_20190930.fna"


