#!/usr/bin/env bash

#SBATCH -c 4
#SBATCH --mem=32000
#SBATCH --partition=short
#SBATCH -o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.fqc.out
#SBATCH -e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.fqc.err
#SBATCH --mail-type=fail
#SBATCH --mail-type=time_limit
#SBATCH --mail-use=velsko@shh.mpg.de
#SBATCH --array=0-121%4
#SBATCH -J "fastqcPhage"

SAMPLES=( $(find /projects1/microbiome_sciences/raw_data/public/abeles2014/ -name '*.trim.fastq.gz' -type f) )
SAMPLENAME=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

unset DISPLAY

fastqc "${SAMPLENAME}" -k 10 -o /projects1/microbiome_calculus/Cameroon_plaque/01-data/phage/abeles2014/fastQC

