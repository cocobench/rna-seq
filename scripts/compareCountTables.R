# arguments:
# count table
# ground truth ground table
# output file

args = commandArgs(T)

CT_path <- snakemake@input[["counts"]] #"gene_counts_test.tsv"
GT_path <- snakemake@input[["truth"]] #"gene_counts.tsv"
output_path <- snakemake@output[[1]] #"output.tsv"

CT <- read.csv(CT_path, sep="\t", row.names = "feature")
GT <- read.csv(GT_path, sep="\t", row.names = "feature")

  #mean gene SD
  #SD_GT <- apply(GT, 1, sd)
  #SD_CT <- apply(CT, 1, sd)
  #mean_SD_GT <- mean(SD_GT)
  #mean_SD_CT <- mean(SD_CT)
  #SD_error <- mean_SD_CT - mean_SD_GT

  #mean sample SD
  #SD_GT_samples <- apply(GT, 2, sd)
  #SD_CT_samples <- apply(CT, 2, sd)
  #mean_SD_GT_samples <- mean(SD_GT_samples)
  #mean_SD_CT_samples <- mean(SD_CT_samples)
  #sample_SD_error <- mean_SD_CT_samples - mean_SD_GT_samples


  #overall SD
  #overall_SD_GT <- sd(unlist(GT))
  #overall_SD_CT <- sd(unlist(CT))
  #overall_SD_error <- overall_SD_CT - overall_SD_GT

# calculate root mean squared errors
error <- CT - GT
error2 <- error^2
rmseSamples <- sqrt(apply(error2, 2, mean))
  #boxplot(rmseSamples)

# calcultae correlations
corSamples <- sapply(colnames(GT), function(x){
  cor(GT[x], CT[x])
})
  #boxplot(corSamples)

# put stats in a dataframe
out <- data.frame(row.names = colnames(GT),
                  correlation=corSamples,
                  rmse=rmseSamples)

write.table(out, output_path,
          sep="\t", quote = F, col.names = NA)
