#!/usr/bin/env bash
 
#SBATCH -c 4
#SBATCH --mem=32000
#SBATCH --partition=medium
#SBATCH -o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.out
#SBATCH -e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.err
#SBATCH --mail-type=fail
#SBATCH --mail-type=time_limit
#SBATCH --mail-use=velsko@shh.mpg.de
#SBATCH --array=0-39%4
#SBATCH -J "cmc_eager"
 
SAMPLES=( $(find /projects1/microbiome_calculus/Cameroon_plaque/03-preprocessing/human_filering/output_JAE/ -name '*.xml' -type f) )
SAMPLENAME=${SAMPLES[$SLURM_ARRAY_TASK_ID]}
 
unset DISPLAY
 
eagercli "${SAMPLENAME}"
