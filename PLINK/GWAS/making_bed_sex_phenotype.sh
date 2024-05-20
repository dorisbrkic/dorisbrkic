#!/bin/bash
# ----------------QSUB Parameters-----------------
#PBS -q q2
#PBS -M dbrkic@bioinfo.hr
#PBS -m n
#PBS -N plink
#PBS -l select=ncpus=15:mem=200g
#PBS -j oe

cd $PBS_O_WORKDIR


# ----------------Commands------------------- #
#recalibrated data 77

plink --vcf /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/GWAS/recalibrated/july/snps77_ann_all.vcf.gz --recode --keep keep_samples.txt --out snps77_ann

#add sex
plink --file snps77_ann --update-sex /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/GWAS/sex_file_3.list --make-bed --out snps3_ann_sex

#fix sex
plink --bfile snps3_ann_sex --impute-sex 0.964 0.969 --make-bed --out snps3_ann_sex_imp

#check sex
plink --bfile snps3_ann_sex_imp --check-sex --out snps3_ann_imp

#add phenotype
plink --bfile snps3_ann_sex --pheno /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/GWAS/pheno_march.list --make-bed --out snps3_ann_sex_pheno
