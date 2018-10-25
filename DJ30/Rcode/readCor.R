setwd("/Users/mac/Desktop/stockData/raw fundamentals/cor/")

# clear environment
rm(list=ls())


files <- list.files()





f <- data.frame()
for (i in 1:length(files)) {
  temp <- as.data.frame(read.csv(files[i])) # read csv as dataframe
  names(temp)[2]<-strsplit(files[i],"_")[[1]][1] # rename col with stock symbol from file name
  # merge dataframes
  if (i==1){
    f <- temp
  } else{
    temp <- temp[-c(1)]
    f <-cbind(f, temp)
  }
}

# calculate row mean
f$mean = round(rowMeans(f[c(-1)],na.rm = T),4)
f <- transform(f, SD=round(apply(f[,2:18],1, sd, na.rm = T),4))


write.csv(f,file = "Pearson_cor_18.csv")
