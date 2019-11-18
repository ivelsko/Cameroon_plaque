#!/bin/bash

#SBATCH -n 16
#SBATCH --mem 50000
#SBATCH --partition=long
#SBATCH -o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.phagespades.out
#SBATCH -e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.phagespades.err
#SBATCH --mail-type=fail
#SBATCH --mail-type=time_limit
#SBATCH --mail-use=velsko@shh.mpg.de
#SBATCH --export=ALL
#SBATCH --array=0-121%4
#SBATCH -J "mSPphage"

SAMPLES=($(find /projects1/microbiome_sciences/raw_data/public/abeles2014/ -name '*trim.fastq.gz' -type f | rev | cut -d/ -f 1 | rev | cut -d. -f1))
SAMPLENAME=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

/projects1/users/fellows/bin.backup/SPAdes-3.12.0-Linux/bin/spades.py \
--iontorrent \
-o /projects1/microbiome_calculus/Cameroon_plaque/01-data/phage/abeles2014/SPAdes-sc/trimmed/"${SAMPLENAME}" \
-s /projects1/microbiome_sciences/raw_data/public/abeles2014/$(echo "$SAMPLENAME").trim.fastq.gz \
--sc \
-t 16 \
-m 250 \
-k 21,33,55

