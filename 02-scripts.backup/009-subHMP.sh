#!/bin/bash

#SBATCH -n 8
#SBATCH --mem 24G
#SBATCH --partition=medium
#SBATCH -o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.out
#SBATCH -e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.err
#SBATCH --mail-type=fail
#SBATCH --mail-type=time_limit
#SBATCH --mail-use=velsko@shh.mpg.de
#SBATCH --export=ALL
#SBATCH --array=0-19%2
#SBATCH -J "subsample"

SAMPLES=($(find /projects1/microbiome_calculus/cameroon_hunter_gatherer_calculus/03-preprocessing/human_filering/input/public_data/*/ -name '*.gz' -type f | rev | cut -d/ -f 1 | rev | cut -d_ -f 1 | sort | uniq))
SAMPLENAME=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

seqtk sample -s100 /projects1/microbiome_calculus/cameroon_hunter_gatherer_calculus/03-preprocessing/human_filering/input/public_data/"$SAMPLENAME"/"$SAMPLENAME"_S0_L001_R1_000.fastq.gz 10000000 > /projects1/microbiome_calculus/cameroon_hunter_gatherer_calculus/03-preprocessing/human_filering/input/public_data/"$SAMPLENAME"10M/"$SAMPLENAME"_S0_L001_R1_000.10M.fastq
pigz -8 /projects1/microbiome_calculus/cameroon_hunter_gatherer_calculus/03-preprocessing/human_filering/input/public_data/"$SAMPLENAME"10M/"$SAMPLENAME"_S0_L001_R1_000.10M.fastq
seqtk sample -s100 /projects1/microbiome_calculus/cameroon_hunter_gatherer_calculus/03-preprocessing/human_filering/input/public_data/"$SAMPLENAME"/"$SAMPLENAME"_S0_L001_R2_000.fastq.gz 10000000 > /projects1/microbiome_calculus/cameroon_hunter_gatherer_calculus/03-preprocessing/human_filering/input/public_data/"$SAMPLENAME"10M/"$SAMPLENAME"_S0_L001_R2_000.10M.fastq
pigz -8 /projects1/microbiome_calculus/cameroon_hunter_gatherer_calculus/03-preprocessing/human_filering/input/public_data/"$SAMPLENAME"10M/"$SAMPLENAME"_S0_L001_R2_000.10M.fastq

