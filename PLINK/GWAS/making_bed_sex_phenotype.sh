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

#keep_samples keeps only samples with high heterozygocity
plink --vcf rmdup_renam_sort.vcf.gz --make-bed --keep keep_samples.txt --out chr122xy_mt189

#add sex
plink --bfile chr122xy_mt189 --update-sex /common1/WORK/dbrkic/Projekti/COVID/WES_Analysis/GWAS/sex_file_9.list --make-bed --out chr122xy_mt189_sex

#check sex
plink --bfile chr122xy_mt189_sex --check-sex --out chr122xy_mt189_sex

#fix sex
plink --bfile chr122xy_mt189_sex --impute-sex 0.965 0.969 --make-bed --out chr122xy_mt189_sex_imp


