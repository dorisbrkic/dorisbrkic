#!/bin/bash
# ----------------QSUB Parameters-----------------
#PBS -q q2
#PBS -M dbrkic@bioinfo.hr
#PBS -m n
#PBS -N plink_assoc_comorb
#PBS -l select=ncpus=15:mem=200g
#PBS -j oe

cd $PBS_O_WORKDIR

###########################################################################################

#making bed files
#comorb_file.list contains number of comorbidities for each person
plink
  --bfile /common1/WORK/dbrkic/Projekti/COVID/WES_Analysis/GWAS/recalibrated/july/snps77_ann_sex
  --make-bed
  --out snps9_ann_comorb
  --pheno comorb_file.list

#QC filtering the dataset
plink 
  --bfile snps9_ann_comorb
  --geno 0.05
  --hwe 0.001
  --maf 0.05
  --make-bed
  --mind 0.05
  --out snps9_ann_comorb_qcfiltered_maf005

#pruning
plink 
  --bfile snps9_ann_comorb_qcfiltered_maf005 
  --indep 50 5 2 
  --out snps9_ann_comorb_qcfiltered_maf005_pruned

plink 
  --bfile snps9_ann_comorb_qcfiltered_maf005 
  --extract snps9_ann_comorb_qcfiltered_maf005_pruned.prune.in 
  --make-bed 
  --out comorb_maf005_pruneddata

#PCA
plink
  --bfile comorb_maf005_pruneddata
  --out comorb_maf005_pca_results
  --pca 10

#adding a header to the PCA file
echo -e "FID\tIID\tPC1\tPC2\tPC3\tPC4\tPC5\tPC6\tPC7\tPC8\tPC9\tPC10" | cat - comorb_maf005_pca_results.eigenvec > comorb_maf005_pca_results_header.eigenvec


#association with number of comorbidities
plink
  --bfile snps9_ann_comorb_qcfiltered_maf005
  --chr 1-22
  --ci 0.95
  --covar comorb_maf005_pca_results_header.eigenvec
  --covar-name PC1-PC10
  --linear sex hide-covar
  --out comorb_maf005_linear_results
