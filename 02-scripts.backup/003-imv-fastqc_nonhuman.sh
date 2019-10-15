#!/usr/bin/env bash

#SBATCH -c 4
#SBATCH --mem=32000
#SBATCH --partition=short
#SBATCH -o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.out
#SBATCH -e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.err
#SBATCH --mail-type=fail
#SBATCH --mail-type=time_limit
#SBATCH --mail-use=velsko@shh.mpg.de
#SBATCH --array=0-101%4
#SBATCH -J "cmc_fastqc"

SAMPLES=( $(find /projects1/microbiome_calculus/cameroon_hunter_gatherer_calculus/03-preprocessing/human_filering/output/ -name '*.combined.fq.prefixed.extractunmapped.bam' -type f) )
SAMPLENAME=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

unset DISPLAY

fastqc "${SAMPLENAME}" -o /projects1/microbiome_calculus/cameroon_hunter_gatherer_calculus/03-preprocessing/human_filering/output/nonhumanFastQC
