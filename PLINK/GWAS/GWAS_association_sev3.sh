#!/bin/bash
# ----------------QSUB Parameters-----------------
#PBS -q q2
#PBS -M dbrkic@bioinfo.hr
#PBS -m n
#PBS -N plink_association_sev3
#PBS -l select=ncpus=15:mem=200g
#PBS -j oe

cd $PBS_O_WORKDIR

# ----------------Commands------------------- #

#keep_samples keeps only samples with high heterozygocity
plink --vcf rmdup_renam_sort.vcf.gz --make-bed --keep keep_samples.txt --out chr122xy_mt189

#add sex
plink --bfile chr122xy_mt189 --update-sex /common1/WORK/dbrkic/Projekti/COVID/WES_Analysis/GWAS/sex_file_9.list --make-bed --out chr122xy_mt189_sex

#check sex
plink --bfile chr122xy_mt189_sex --check-sex --out chr122xy_mt189_sex

#fix sex
plink --bfile chr122xy_mt189_sex --impute-sex 0.965 0.969 --make-bed --out chr122xy_mt189_sex_imp

#QC filtering and adding phenotype
plink 
  --bfile chr122xy_mt189_sex_imp 
  --geno 0.05 
  --hwe 0.001 
  --maf 0.05 
  --make-bed 
  --mind 0.05 
  --out sev3_qcfiltered_maf005_mt 
  --pheno /common1/WORK/dbrkic/Projekti/COVID/WES_Analysis/GWAS/recalibrated/november/november_192phenotypes_gwas.list 
  --pheno-name severity.nov.coded3

#pruning
plink 
  --bfile sev3_qcfiltered_maf005_mt 
  --indep 50 5 2 
  --out sev3_qcfiltered_maf005_mt_pruned

plink 
  --bfile sev3_qcfiltered_maf005_mt 
  --extract sev3_qcfiltered_maf005_mt_pruned.prune.in 
  --make-bed 
  --out sev3_qcfiltered_maf005_mt_pruneddata

#PCA
plink 
  --bfile sev3_qcfiltered_maf005_mt_pruneddata 
  --pca 10 
  --out sev3_qcfiltered_maf005_mt_pca_results

#adding a header to the PCA file
echo -e "FID\tIID\tPC1\tPC2\tPC3\tPC4\tPC5\tPC6\tPC7\tPC8\tPC9\tPC10" | cat - sev3_qcfiltered_maf005_mt_pca_results.eigenvec > sev3_qcfiltered_maf005_mt_pca_results_header.eigenvec

#association with all chromosomes
plink --bfile sev3_qcfiltered_maf005_mt --linear sex hide-covar --covar sev3_qcfiltered_maf005_mt_pca_results_header.eigenvec --covar-name PC1-PC10 --ci 0.95 --adjust --out sev3_qcfiltered_maf005_mt_linear_results
