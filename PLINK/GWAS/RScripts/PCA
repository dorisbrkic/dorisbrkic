#interactive R in Unix

source activate r_env

R

library(ggplot2)
library(magrittr)
library(dplyr)

ret_pca<-read.table("sev3_qcfiltered_maf005_mt_pca_results_header.eigenvec", header=T) %>% as_tibble()

plot1 <- ggplot(ret_pca, aes(x=PC1,y=PC2)) + geom_point()

ggsave("sev3_qcfiltered_maf005_mt_pca.png", plot = plot1, device="png")

q()
n
