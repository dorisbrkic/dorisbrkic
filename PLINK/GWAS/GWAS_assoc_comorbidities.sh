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

#PCA
plink
  --bfile comorb_maf005_pruneddata
  --out comorb_maf005_pca_results
  --pca

#association with number of comorbidities
plink
  --bfile snps9_ann_comorb_qcfiltered_maf005
  --chr 1-22
  --ci 0.95
  --covar comorb_maf005_pca_results_header.eigenvec
  --covar-name PC1-PC10
  --linear sex hide-covar
  --out comorb_maf005_linear_results
