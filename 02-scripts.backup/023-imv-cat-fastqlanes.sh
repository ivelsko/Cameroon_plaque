#!/usr/bin/env bash

#SBATCH -c 2
#SBATCH --mem=2G
#SBATCH --partition=long
#SBATCH -o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.out
#SBATCH -e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.err
#SBATCH --mail-type=fail
#SBATCH --mail-use=velsko@shh.mpg.de
#SBATCH --array=0-116%6
#SBATCH -J "catcmc"

SAMPLES=( $(find /rawdata1/releases/2019/190823_NS500559_0067_AHW5NVBGX9/*/ -name '*' -type d | rev | cut -d/ -f 2 | rev | grep -v Unassigned) )
SAMPLENAME=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

cat /rawdata1/releases/2019/190823_NS500559_0067_AHW5NVBGX9/"$SAMPLENAME"/"$SAMPLENAME"_S0_L001_R1_001.fastq.gz /rawdata1/releases/2019/190823_NS500559_0067_AHW5NVBGX9/"$SAMPLENAME"/"$SAMPLENAME"_S0_L002_R1_001.fastq.gz /rawdata1/releases/2019/190823_NS500559_0067_AHW5NVBGX9/"$SAMPLENAME"/"$SAMPLENAME"_S0_L003_R1_001.fastq.gz /rawdata1/releases/2019/190823_NS500559_0067_AHW5NVBGX9/"$SAMPLENAME"/"$SAMPLENAME"_S0_L004_R1_001.fastq.gz > /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/assembly/input/"$SAMPLENAME".R1.fastq.gz

cat /rawdata1/releases/2019/190823_NS500559_0067_AHW5NVBGX9/"$SAMPLENAME"/"$SAMPLENAME"_S0_L001_R2_001.fastq.gz /rawdata1/releases/2019/190823_NS500559_0067_AHW5NVBGX9/"$SAMPLENAME"/"$SAMPLENAME"_S0_L002_R2_001.fastq.gz /rawdata1/releases/2019/190823_NS500559_0067_AHW5NVBGX9/"$SAMPLENAME"/"$SAMPLENAME"_S0_L003_R2_001.fastq.gz /rawdata1/releases/2019/190823_NS500559_0067_AHW5NVBGX9/"$SAMPLENAME"/"$SAMPLENAME"_S0_L004_R2_001.fastq.gz > /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/assembly/input/"$SAMPLENAME".R2.fastq.gz
