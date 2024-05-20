#interactive R in Unix
source activate r_env

R

library(qqman)
library(data.table)
library(writexl)
library(dplyr)

results<-as.data.frame(fread("sev3_qcfiltered_maf005_mt_linear_results.assoc.linear", header=T, sep=" ", stringsAsFactors=FALSE))

png("Manhattan_sev3_qcfiltered_maf005_mt.png")
manhattan(results, chr="CHR", bp="BP", snp="SNP", p="P", main="Manhattan Plot of severity 1-3 (189 individuals)", col = c("blue","orange","red","purple"), chrlabs = NULL,
  suggestiveline = -log10(1e-05), genomewideline = -log10(5e-08), highlight = NULL, logp = TRUE, annotatePval=0.00001, ylim = c(0, 8.5))
dev.off()

png("qqlot_sev3_qcfiltered_maf005_mt.png")
qq(results$P, main="QQ plot of linear severity MAF>5%")
dev.off()

results_sorted <- results[order(results$P), ]

p.adj <- as.data.frame(fread("sev4_nohetnohet_maf005_linear_results.assoc.linear.adjusted", header=T, sep=" ", stringsAsFactors=FALSE))

joined <- left_join(results_sorted, p.adj)

top30<-results_sorted[1:30,]

write_xlsx(top30, "Top30_sev3_qcfiltered_maf005_mt_variants.xlsx")

q()
n
