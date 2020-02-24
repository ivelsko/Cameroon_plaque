#!/usr/bin/env bash

#SBATCH -n 112
#SBATCH --mem 1950G
#SBATCH --partition=supercruncher
#SBATCH -o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.aadderbuild.out
#SBATCH -e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.aadderbuild.err
#SBATCH --mail-type=end
#SBATCH --mail-type=fail
#SBATCH --mail-user=velsko@shh.mpg.de
#SBATCH -J "AADDER-build"
#SBATCH -d afterok:686709

/projects1/users/velsko/bin/megan_6_18_5/tools/aadder-build \
-igff /projects1/microbiome_sciences/reference_databases/refseq/genomes/bacteria_archea_homo_20181122/raw \
-d  /projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/aadder/Oct2019/ \
-a2t /projects1/microbiome_calculus/Cameroon_plaque/01-data/databases/megan_mapping_files/megan-nucl-Oct2019.db \
-ex \
-v
