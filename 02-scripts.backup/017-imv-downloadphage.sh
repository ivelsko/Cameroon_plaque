#!/usr/bin/env bash

#sbatch \
#-c 2 \
#--mem 4G \
#--partition=short \
#-o ~/slurm_logs/slurm.%j.out \
#-e ~/slurm_logs/slurm.%j.err \
#--mail-type=fail \
#--mail-user=velsko@shh.mpg.de \
#-J "phage" \
#--wrap="/projects1/clusterhomes/velsko/bin/MG-RAST-Tools/scripts/mg-download.py --project mgp7236 --dir /projects1/microbiome_sciences/raw_data/public/abeles2014"



# /projects1/microbiome_sciences/raw_data/public/abeles2014/mgrastlist.txt

while read FILE; do
        sbatch \
        --partition=short \
        -c 2 \
        --mem 4000 \
        -o ~/slurm_logs/slurm.%j.out \
        -e ~/slurm_logs/slurm.%j.err \
        -J "mgrast_download" \
        --wrap="/projects1/clusterhomes/velsko/bin/MG-RAST-Tools/scripts/mg-download.py --metagenome $FILE --dir /projects1/microbiome_sciences/raw_data/public/abeles2014"
done <$1
 
exit 0

