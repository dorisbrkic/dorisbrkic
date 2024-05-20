#!/bin/bash
# ----------------QSUB Parameters-----------------
#PBS -q q2
#PBS -M dbrkic@bioinfo.hr
#PBS -m n
#PBS -N SnpSift_SnpEff
#PBS -l select=ncpus=16:mem=500g
#PBS -j oe
cd $PBS_O_WORKDIR

# ----------------Loading variables------------------- #

#renaming chrM to chrMT
bcftools annotate /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/Annotation/snps_recal_all67_xym.vcf.gz --rename-chrs /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/Annotation/mtDNA/chr_name_conv.txt -o /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/Annotation/snps_recal_all67_xym_renamedM.vcf

bgzip -c /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/Annotation/snps_recal_all67_xym_renamedM.vcf > /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/Annotation/snps_recal_all67_xym_renamedM.vcf.gz
tabix -p vcf /common/WORK/dbrkic/Projekti/COVID/WES_Analysis/Annotation/snps_recal_all67_xym_renamedM.vcf.gz

CLINVAR=/common/WORK/dbrkic/Projekti/COVID/WES_Analysis/Annotation/ClinVar/clinvar.vcf.gz
DBSNP=/common/WORK/dbrkic/Projekti/COVID/WES_Analysis/Annotation/dbSNP/00-All.vcf.gz

#snpSift
SnpSift annotate -id ${DBSNP} \
-Xmx20G \
/common/WORK/dbrkic/Projekti/COVID/WES_Analysis/Annotation/snps_recal_all67_xym_renamedM.vcf.gz > snps77_ann_dbsnp.vcf

#snpSift
SnpSift annotate -id ${CLINVAR} \
-Xmx20G \
snps77_ann_dbsnp.vcf > snps77_ann_both.vcf

#snpEff
snpEff eff -Xmx20G -v GRCh38.p14 \
snps77_ann_both.vcf > snps77_ann_all.vcf

bgzip snps77_ann_dbsnp.vcf
bgzip snps77_ann_both.vcf
bgzip snps77_ann_all.vcf
