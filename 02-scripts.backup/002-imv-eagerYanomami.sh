#!/usr/bin/env bash
 
#SBATCH -c 4
#SBATCH --mem=48000
#SBATCH --partition=medium
#SBATCH -o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.eager.out
#SBATCH -e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.eager.err
#SBATCH --mail-type=fail
#SBATCH --mail-type=time_limit
#SBATCH --mail-use=velsko@shh.mpg.de
#SBATCH --array=0-13%4
#SBATCH -J "cmc_eager"
 
SAMPLES=( $(find /projects1/microbiome_calculus/Cameroon_plaque/03-preprocessing/human_filering/output_yanomami/ -name '*.xml' -type f) )
SAMPLENAME=${SAMPLES[$SLURM_ARRAY_TASK_ID]}
 
unset DISPLAY
 
eagercli "${SAMPLENAME}"
