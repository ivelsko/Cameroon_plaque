#!/usr/bin/env bash

#SBATCH -c 12
#SBATCH --mem=12000
#SBATCH --partition=medium
#SBATCH -o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.out
#SBATCH -e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.err
#SBATCH --mail-type=fail
#SBATCH --mail-type=time_limit
#SBATCH --mail-use=velsko@shh.mpg.de
#SBATCH --array=0-39%4
#SBATCH -J "sam2fastq"

SAMPLES=( $(find /projects1/microbiome_calculus/Cameroon_plaque/03-preprocessing/human_filering/output_JAE/ -name '*.fastq.combined.fq.prefixed.extractunmapped.bam' -type f) )
SAMPLENAME=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

samtools fastq "$SAMPLENAME" > $(echo "$SAMPLENAME").fastq
pigz -12 $(echo "$SAMPLENAME").fastq
