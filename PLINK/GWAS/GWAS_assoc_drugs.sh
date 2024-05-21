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
#drug_linear_pheno.list contains number of drugs for each person
plink
  --bfile /common1/WORK/dbrkic/Projekti/COVID/WES_Analysis/GWAS/recalibrated/july/snps77_ann_sex
  --make-bed
  --out snps77_ann_sex_drug_lin
  --pheno drug_linear_pheno.list

#QC filtering the dataset
plink
  --bfile snps77_ann_sex_drug_lin
  --geno 0.05
  --hwe 0.001
  --maf 0.05
  --make-bed
  --mind 0.05
  --out drug_qcfiltered_maf005

#pruning
plink 
  --bfile drug_qcfiltered_maf005
  --indep 50 5 2
  --out drug_maf005_pruned

plink 
  --bfile drug_qcfiltered_maf005 
  --extract drug_maf005_pruned.prune.in 
  --make-bed 
  --out drug_maf005_pruneddata

  #PCA
  plink
  --bfile drug_qcfiltered_maf005
  --extract drug_maf005_pruned.prune.in
  --out drug_maf005_pca_results
  --pca 10

  #adding a header to the PCA file
echo -e "FID\tIID\tPC1\tPC2\tPC3\tPC4\tPC5\tPC6\tPC7\tPC8\tPC9\tPC10" | cat - drug_maf005_pca_results.eigenvec > drug_maf005_pca_results_header.eigenvec

#association with number of drugs
plink
  --bfile drug_qcfiltered_maf005
  --chr 1-22
  --ci 0.95
  --covar drug_maf005_pca_results_header.eigenvec
  --covar-name PC1-PC10
  --linear sex
  --out drug_maf005_linear_results
