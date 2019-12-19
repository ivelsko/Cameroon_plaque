# malt-nt CMC only
grep "Num. of queries:" ../00-documentation.backup/malt-genbank_rma_20190903.log > ../00-documentation.backup/CMC_nt_numbers.txt
grep "Aligned queries:" ../00-documentation.backup/malt-genbank_rma_20190903.log > ../00-documentation.backup/CMC_nt_aligned.txt
ls ../04-analysis/malt/nt/*.rma6 > ../00-documentation.backup/CMC_nt_names.txt
paste ../00-documentation.backup/CMC_nt_names.txt ../00-documentation.backup/CMC_nt_numbers.txt ../00-documentation.backup/CMC_nt_aligned.txt > ../00-documentation.backup/CMC_nt_aligned_stats.tsv

# malt-RefSeqCustom CMC only
grep "Num. of queries:" ../00-documentation.backup/malt-genbank_rma_20190925.log > ../00-documentation.backup/CMCnumbers.txt
grep "Aligned queries:" ../00-documentation.backup/malt-genbank_rma_20190925.log > ../00-documentation.backup/CMCaligned.txt
ls ../04-analysis/malt/RefSeqCustom/*.rma6 | grep -v SRR | grep -v JAE > ../00-documentation.backup/CMCnames.txt
paste ../00-documentation.backup/CMCnames.txt ../00-documentation.backup/CMCnumbers.txt ../00-documentation.backup/CMCaligned.txt > ../00-documentation.backup/CMC_RSC_aligned_stats.tsv

# malt-RefSeqCustom HMP only
grep "Num. of queries:" ../00-documentation.backup/malt-genbank_rma_20190930.log > ../00-documentation.backup/HMPnumbers.txt
grep "Aligned queries:" ../00-documentation.backup/malt-genbank_rma_20190930.log > ../00-documentation.backup/HMPaligned.txt
ls ../04-analysis/malt/RefSeqCustom/SRR*.bam.rma6 > ../00-documentation.backup/HMPnames.txt
paste ../00-documentation.backup/HMPnames.txt ../00-documentation.backup/HMPnumbers.txt ../00-documentation.backup/HMPaligned.txt > ../00-documentation.backup/HMP_RSC_aligned_stats.tsv

# malt-RefSeqCustom JAE only
grep "Num. of queries:" ../00-documentation.backup/malt-genbank_rma_20191021.log > ../00-documentation.backup/JAEnumbers.txt
grep "Aligned queries:" ../00-documentation.backup/malt-genbank_rma_20191021.log > ../00-documentation.backup/JAEaligned.txt
ls ../04-analysis/malt/RefSeqCustom/JAE*.rma6 > ../00-documentation.backup/JAEnames.txt
paste ../00-documentation.backup/JAEnames.txt ../00-documentation.backup/JAEnumbers.txt ../00-documentation.backup/JAEaligned.txt > ../00-documentation.backup/JAE_RSC_aligned_stats.tsv

# malt-RefSeqCustom Yanomami only
grep "Num. of queries:" ../00-documentation.backup/malt-genbank_rma_20191218.log > ../00-documentation.backup/Yanomaminumbers.txt
grep "Aligned queries:" ../00-documentation.backup/malt-genbank_rma_20191218.log > ../00-documentation.backup/Yanomamialigned.txt
ls ../04-analysis/malt/RefSeqCustom/SRR*.truncated.rma6 > ../00-documentation.backup/Yanomaminames.txt
paste ../00-documentation.backup/Yanomaminames.txt ../00-documentation.backup/Yanomaminumbers.txt ../00-documentation.backup/Yanomamialigned.txt > ../00-documentation.backup/Yanomami_RSC_aligned_stats.tsv

# combine CMC, HMP, and JAE RefSeqCustom stats files
cat ../00-documentation.backup/CMC_RSC_aligned_stats.tsv ../00-documentation.backup/HMP_RSC_aligned_stats.tsv ../00-documentation.backup/JAE_RSC_aligned_stats.tsv ../00-documentation.backup/Yanomami_RSC_aligned_stats.tsv > ../00-documentation.backup/CMC_HMP_JAE_Yano_RSC_aligned_stats.tsv

perl -p -i -e 's/ //g' ../00-documentation.backup/CMC_nt_aligned_stats.tsv
perl -p -i -e 's/Num.ofqueries://g' ../00-documentation.backup/CMC_nt_aligned_stats.tsv
perl -p -i -e 's/Alignedqueries://g' ../00-documentation.backup/CMC_nt_aligned_stats.tsv

perl -p -i -e 's/ //g' ../00-documentation.backup/CMC_RSC_aligned_stats.tsv
perl -p -i -e 's/Num.ofqueries://g' ../00-documentation.backup/CMC_RSC_aligned_stats.tsv
perl -p -i -e 's/Alignedqueries://g' ../00-documentation.backup/CMC_RSC_aligned_stats.tsv

perl -p -i -e 's/ //g' ../00-documentation.backup/HMP_RSC_aligned_stats.tsv
perl -p -i -e 's/Num.ofqueries://g' ../00-documentation.backup/HMP_RSC_aligned_stats.tsv
perl -p -i -e 's/Alignedqueries://g' ../00-documentation.backup/HMP_RSC_aligned_stats.tsv

perl -p -i -e 's/ //g' ../00-documentation.backup/CMC_HMP_RSC_aligned_stats.tsv
perl -p -i -e 's/Num.ofqueries://g' ../00-documentation.backup/CMC_HMP_RSC_aligned_stats.tsv
perl -p -i -e 's/Alignedqueries://g' ../00-documentation.backup/CMC_HMP_RSC_aligned_stats.tsv

perl -p -i -e 's/ //g' ../00-documentation.backup/CMC_HMP_JAE_RSC_aligned_stats.tsv
perl -p -i -e 's/Num.ofqueries://g' ../00-documentation.backup/CMC_HMP_JAE_RSC_aligned_stats.tsv
perl -p -i -e 's/Alignedqueries://g' ../00-documentation.backup/CMC_HMP_JAE_RSC_aligned_stats.tsv

perl -p -i -e 's/ //g' ../00-documentation.backup/CMC_HMP_JAE_Yano_RSC_aligned_stats.tsv
perl -p -i -e 's/Num.ofqueries://g' ../00-documentation.backup/CMC_HMP_JAE_Yano_RSC_aligned_stats.tsv
perl -p -i -e 's/Alignedqueries://g' ../00-documentation.backup/CMC_HMP_JAE_Yano_RSC_aligned_stats.tsv

rm ../00-documentation.backup/*numbers.txt
rm ../00-documentation.backup/*aligned.txt
rm ../00-documentation.backup/*names.txt
# manually add column titles SampleID, Queries, Aligned

