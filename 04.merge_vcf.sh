#!/bin/bash
# ----------------QSUB Parameters-----------------
#PBS -q q2
#PBS -M dbrkic@bioinfo.hr
#PBS -m n
#PBS -N merge_vcf
#PBS -l select=ncpus=5:mem=50g
#PBS -j oe

#merging recalibrated and filtered SNPs before annotation

#batch1
bcftools merge /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/VarCall/seq_batch1/recal_filtered_snps/*_recal_filtered_snps.vcf.gz -m snps -0 -O z -o /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/VarCall/snps_recal_batch1.vcf.gz
bcftools index /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/VarCall/snps_recal_batch1.vcf.gz

#batch2
bcftools merge /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/VarCall/seq_batch2/recal_filtered_snps/*_recal_filtered_snps.vcf.gz -m snps -0 -O z -o /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/VarCall/snps_recal_batch2.vcf.gz
bcftools index /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/VarCall/snps_recal_batch2.vcf.gz

#merging batches, 67 means July 6th
bcftools merge /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/VarCall/snps_recal_batch1.vcf.gz /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/VarCall/snps_recal_batch2.vcf.gz -0 -O z -o /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/VarCall/snps_recal_all67.vcf.gz

#taking specific chromosomes
bcftools view /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/VarCall/snps_recal_all67.vcf.gz | grep -w '^#\|^#CHROM\|chr[1-9]\|chr[1-2][0-9]\|chr[X]\|chr[Y]\|chr[M]' > /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/VarCall/snps_recal_all67_xym.vcf.gz
