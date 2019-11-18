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
#SBATCH --array=0-9%2
#SBATCH -J "subsample"

SAMPLES=($(find /projects1/microbiome_calculus/Cameroon_plaque/03-preprocessing/human_filering/output_JAE/*/ -name '*.bam.fastq.gz' -type f | rev | cut -d/ -f 1 | rev | cut -d_ -f 1 | sort | uniq))
SAMPLENAME=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

seqtk sample -s100 /projects1/microbiome_calculus/Cameroon_plaque/03-preprocessing/human_filering/output_JAE/"$SAMPLENAME"/4-Samtools/"$SAMPLENAME"_S0_L001_R1_001.fastq.combined.fq.prefixed.extractunmapped.bam.fastq.gz 10000000 > /projects1/microbiome_calculus/Cameroon_plaque/03-preprocessing/human_filering/output_JAE/"$SAMPLENAME"_S0_L001_R1_001.fastq.combined.fq.prefixed.extractunmapped.bam.10M.fastq.gz
