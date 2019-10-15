#gzip large files
#!/usr/bin/env bash

while read FILE; do
        sbatch \
        -c 4 \
        --mem 8000 \
        -o ~/slurm_logs/slurm.%j.out \
        -e ~/slurm_logs/slurm.%j.err \
        --mail-type=fail \
        --mail-type=time_limit \
        --mail-user=velsko@shh.mpg.de \
        --partition=short \
        --wrap="pigz -4 $FILE"
done <$1
 
exit 0
