# Combine all stocks' relative return into one matrix
library(plyr)
library(reshape)

setwd("/Users/mac/Desktop/stockData/DJ30")
rm(list=ls())

path <- "../DJ30/formatedData"
file.names <- dir(path,pattern = "*.csv")


setwd("/Users/mac/Desktop/stockData/DJ30/originalData")

rrtable <- data.frame()

for (i in 1:length(file.names)){
  
  if(i==1){
    rrtable <- read.csv(file.names[i])
  }else{
    rrtable <- 
  }

}


# filenames <- list.files(path = "./formatedData/", full.names = T)
# import.list <- llply(filenames, read.csv)
# 
# data <- merge_recurse(import.list,2)
