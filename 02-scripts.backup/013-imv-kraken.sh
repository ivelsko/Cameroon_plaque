#!/usr/bin/env bash

#SBATCH -c 8
#SBATCH --mem=100000
#SBATCH --partition=medium
#SBATCH -o /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.kraken.5.rso.out
#SBATCH -e /projects1/clusterhomes/velsko/slurm_logs/slurm.%j.kraken.5.rso.err
#SBATCH --mail-type=fail
#SBATCH --mail-type=time_limit
#SBATCH --mail-use=velsko@shh.mpg.de
#SBATCH --array=0-162%4
#SBATCH -J "kraken"

SAMPLES=( $(find /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/kraken/input-temp/ -name '*.gz' | rev | cut -d/ -f 1 | rev))
SAMPLENAME=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

/projects1/users/velsko/bin/kraken2-2.0.8-beta/kraken2 \
--db /projects1/microbiome_sciences/reference_databases/refseq20191017/kraken2_db/MiniKraken_RefSeq1910 \
--threads 8 \
--gzip-compressed \
--output /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/kraken/output/$(basename "$SAMPLENAME" _S0_L001_R1_001.fastq.combined.fq.prefixed.extractunmapped.bam.10M.fastq.gz).output.5.rso.kraken \
--report /projects1/microbiome_calculus/Cameroon_plaque/04-analysis/kraken/output/$(basename "$SAMPLENAME" _S0_L001_R1_001.fastq.combined.fq.prefixed.extractunmapped.bam.10M.fastq.gz).report.5.rso.kraken \
--use-mpa-style \
/projects1/microbiome_calculus/Cameroon_plaque/04-analysis/kraken/input-temp/"${SAMPLENAME}"

# use the database below for RefSeqCustom plus Pasolli MAGs:
#/projects1/microbiome_sciences/reference_databases/refseq20191017_Pasolli2019/kraken2_db/MiniKraken_RefSeq1910PlusPasolliSGBs \
