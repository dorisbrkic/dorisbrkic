#!/bin/bash
# ----------------QSUB Parameters-----------------
#PBS -q q2
#PBS -M dbrkic@bioinfo.hr
#PBS -m n
#PBS -N plink_association
#PBS -l select=ncpus=15:mem=200g
#PBS -j oe

cd $PBS_O_WORKDIR

###########################################################################################

#filtering and adding phenotype
plink --bfile chr122xy_mt189_sex_imp --geno 0.05 --hwe 0.001 --maf 0.05 --make-bed --mind 0.05 --out sev3_qcfiltered_maf005_mt --pheno /common1/WORK/dbrkic/Projekti/COVID/WES_Analysis/GWAS/recalibrated/november/november_192phenotypes_gwas.list --pheno-name severity.nov.coded3

#pruning
plink --bfile sev3_qcfiltered_maf005_mt --indep 50 5 2 --out sev3_qcfiltered_maf005_mt_pruned

plink --bfile sev3_qcfiltered_maf005_mt --extract sev3_qcfiltered_maf005_mt_pruned.prune.in --make-bed --out sev3_qcfiltered_maf005_mt_pruneddata

#PCA
plink --bfile sev3_qcfiltered_maf005_mt_pruneddata --pca 10 --out sev3_qcfiltered_maf005_mt_pca_results

##adding a header to the PCA file
echo -e "FID\tIID\tPC1\tPC2\tPC3\tPC4\tPC5\tPC6\tPC7\tPC8\tPC9\tPC10" | cat - sev3_qcfiltered_maf005_mt_pca_results.eigenvec > sev3_qcfiltered_maf005_mt_pca_results_header.eigenvec
