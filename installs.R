
toInstall <- c("ROAuth", "igraph", "ggplot2", "wordcloud", "devtools", "tm",
               "R2WinBUGS", "rmongodb", "scales")
install.packages(toInstall, repos = "http://cran.r-project.org")
library(devtools)
# R packages to get twitter and Facebook data
install.packages("streamR")
library(streamR)
install.packages("Rfacebook")
library(Rfacebook)
# smapp R package
install.packages("smappR")
# install_github("smappR", "SMAPPNYU")
library(smappR)

install_github("twitteR", username="geoffjentry")
library(twitteR)



