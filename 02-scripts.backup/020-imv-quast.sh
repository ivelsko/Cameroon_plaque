#!/usr/bin/env bash
# file is /projects1/microbiome_calculus/Cameroon_plaque/01-data/phage/abeles2014assemblies/SPAdes/scaffolds.list

while read FILE; do
        sbatch \
        -c 2 \
        --mem 4000 \
        -o ~/slurm_logs/slurm.%j.out \
        -e ~/slurm_logs/slurm.%j.err \
        --mail-type=fail \
        --mail-type=time_limit \
        --mail-user=velsko@shh.mpg.de \
        --partition=short \
        -J "quastPhage" \
        --wrap="quast.py $FILE -o /projects1/microbiome_calculus/Cameroon_plaque/01-data/phage/abeles2014assemblies/SPAdes-sc/quast/$(echo "$FILE" | rev | cut -d/ -f 2 | rev | cut -d. -f1)_scaffolds"
done <$1

exit 0

