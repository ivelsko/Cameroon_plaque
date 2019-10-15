cat /projects1/microbiome_sciences/raw_data/internal.backup/library_import_list_20190826_1.txt | while read line; do ln -s /projects1/microbiome_sciences/raw_data/internal.backup/$line /projects1/microbiome_calculus/cameroon_hunter_gatherer_calculus/01-data/screening/$line; done

cat /projects1/microbiome_sciences/raw_data/internal.backup/library_import_list_20190826_1.txt | while read line; do ln -s /projects1/microbiome_sciences/raw_data/internal.backup/$line /projects1/microbiome_calculus/cameroon_hunter_gatherer_calculus/03-preprocessing/human_filering/input/nextseq_paired/$line; done
