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

#association with all chromosomes
plink --bfile sev3_qcfiltered_maf005_mt --linear sex hide-covar --covar sev3_qcfiltered_maf005_mt_pca_results_header.eigenvec --covar-name PC1-PC10 --ci 0.95 --adjust --out sev3_qcfiltered_maf005_mt_linear_results
