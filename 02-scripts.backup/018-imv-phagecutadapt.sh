#!/usr/bin/env bash

#SBATCH -c 1
#SBATCH --mem=3200
#SBATCH --partition=short
#SBATCH -o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.cut.out
#SBATCH -e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.cut.err
#SBATCH --mail-type=fail
#SBATCH --mail-type=time_limit
#SBATCH --mail-use=velsko@shh.mpg.de
#SBATCH --array=0-121%4
#SBATCH -J "cutadapt"

SAMPLES=($(find /projects1/microbiome_sciences/raw_data/public/abeles2014/ -name '*.gz' -type f))
#SAMPLES=($(find /projects1/microbiome_sciences/raw_data/public/abeles2014/ -name '*.trim.fastq.gz' -type f) )
SAMPLENAME=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

#cutadapt -a GCCTACGGGAGGCAGCAGTAGGGAATCTTCGGCAATGGACG -m 50 -M 300 --max-n 0.25 -o $(basename "$SAMPLENAME" .fastq.gz).trim.fastq.gz "${SAMPLENAME}"

#cutadapt -a GCCTACGGGAGGCAGCAGTAGGGAATCTTCGGCAATGGACG -m 50 -M 300 --max-n 0.25 -o $(basename "$SAMPLENAME" .trim.fastq.gz).trim2.fastq.gz "${SAMPLENAME}"

cutadapt -u 15 -m 50 -M 300 --max-n 0.25 -o $(basename "$SAMPLENAME" .fastq.gz).trim.fastq.gz "${SAMPLENAME}"
#mv *.gz /projects1/microbiome_sciences/raw_data/public/abeles2014
