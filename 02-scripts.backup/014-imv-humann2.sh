#!/bin/bash

#SBATCH -n 8
#SBATCH --mem 64000
#SBATCH -t 0-48:00
#SBATCH --partition=medium
#SBATCH --array=0-161%5
#SBATCH -o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.humann2.out
#SBATCH -e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.humann2.err
#SBATCH --mail-type=FAIL,ARRAY_TASKS
#SBATCH --mail-type=time_limit
#SBATCH --mail-use=velsko@shh.mpg.de
#SBATCH -J "CMC_humann2"

SAMPLES=($(find /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/humann2/input -name '*.gz'  | rev | cut -d/ -f 1 | rev))
SAMPLENAME=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

humann2 \
--input /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/humann2/input/"${SAMPLENAME}" \
--output /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/humann2/output/$(basename "$SAMPLENAME" _S0_L001_R1_001.fastq.combined.fq.prefixed.extractunmapped.bam.fastq.gz)/  \
--nucleotide-database /projects1/users/huebner/src/humann2/chocophlan \
--protein-database /projects1/users/huebner/src/humann2/uniref \
--threads 8 \
--remove-temp-output \
--memory-use maximum

