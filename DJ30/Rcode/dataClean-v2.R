# loop through files in folder for data preparation

setwd("/Users/mac/Desktop/stockData/DJ30")
library(dplyr)
library(xts)
library(data.table)
library(corrplot)

# clear environment
rm(list=ls())

path <- "../DJ30/originalData"
file.names <- dir(path,pattern = "*.csv")

# files <- list.files(path = "../DJ30/originalData",
#                     pattern = "*.csv",
#                     full.names = TRUE,
#                     recursive = FALSE)

# files <- files[!file.info(files)$isdir]
setwd("/Users/mac/Desktop/stockData/DJ30/originalData")

for (i in 1:length(file.names)){
  # load data
  rawdata = read.csv(file.names[i])
  
  # Rename SE to Book.value
  colnames(rawdata)[colnames(rawdata)=="Shareholders.equity"] <- "Book.value"
  
  # Drop columns (including date [1])
  selectedData = rawdata[,-c(2, 4, 10:13, 16:19, 29:31, 33:39)]
  
  # Reverse row order
  selectedData = arrange(selectedData, -row_number())
  
  # Replace all "None" with NA
  selectedData[,2:21] <- as.data.frame(lapply(selectedData[,2:21], function(x) {
    x <- as.character(x)
    x[x == "None"] <- NA
    as.numeric(x)
  }))
  
  ### Check the rows with NA manually
  
  
  # Omit rows with at least one NA
  selectedData = selectedData[complete.cases(selectedData),]
  
  # Divide the large values by 1000000
  selectedData[,c(3:15)] = selectedData[,c(3:15)] / 1000000
  
  # Add columns -- ROA, Net.margin, Asset.turnover
  selectedData$Net.margin = round((selectedData$Earnings / selectedData$Revenue)*100, digits = 4)
  
  selectedData$ROA = round(selectedData$Earnings / selectedData$Assets, digits = 4)
  
  selectedData$Asset.turnover = round(selectedData$Revenue / selectedData$Assets, digits = 4)
  
  # Move Price column to the end
  selectedData = selectedData[,c(setdiff(names(selectedData),c("Price")), c("Price"))]
  
  # Further drop columns by name
  selectedData = selectedData[, -which(names(selectedData) %in% c("Shares.split.adjusted", "Price.high", "Price.low"))]
  
  ##### In order to do differecing easily, we need to transform the data frame into ts object
  
  
  # For date in format "%m/%d/%Y" Only
  #date <- strptime(as.character(selectedData$Quarter.end), "%m/%d/%y")
  #date <- format(date, "%Y-%m-%d")
  
  # Convert 'Quarter.end' to Date class
  
  # For AAPL
  #date = as.Date(as.character(selectedData$Quarter.end),"%m/%d/%y")
  # For others
  date = as.Date(as.character(selectedData$Quarter.end),"%Y-%m-%d")
  # Create xts object
  myXts = xts(selectedData[,2:21], date)
  # colnames(myXts)
  
  
  
  ## Add a function to do all these below!!
  myXts$Assets.Q = round(diff(myXts$Assets, lag = 1)/lag(myXts$Assets)*100,4)
  
  myXts$Current.Assets.Q = round(diff(myXts$Current.Assets, lag = 1)/lag(myXts$Current.Assets)*100, 4)
  
  myXts$Liabilities.Q = round(diff(myXts$Liabilities, lag =1)/lag(myXts$Liabilities)*100,4)
  
  myXts$Current.Liabilities.Q = round(diff(myXts$Current.Liabilities, lag = 1)/lag(myXts$Current.Liabilities)*100,4)
  
  myXts$Book.value.Q = round(diff(myXts$Book.value, lag = 1)/lag(myXts$Book.value)*100,4)
  
  myXts$Revenue.Q = round(diff(myXts$Revenue, lag = 1)/lag(myXts$Revenue)*100,4)
  
  myXts$Earnings.Q = round(diff(myXts$Earnings, lag = 1)/lag(myXts$Earnings)*100,4)
  
  myXts$Cash.from.operating.activities.Q = round(diff(myXts$Cash.from.operating.activities, lag = 1)/lag(myXts$Cash.from.operating.activities)*100,4)
  
  myXts$Cash.from.investing.activities.Q = round(diff(myXts$Cash.from.investing.activities, lag = 1)/lag(myXts$Cash.from.investing.activities)*100,4)
  
  myXts$Cash.from.financing.activities.Q = round(diff(myXts$Cash.from.financing.activities, lag = 1)/lag(myXts$Cash.from.financing.activities)*100,4)
  
  myXts$Cash.at.end.of.period.Q = round(diff(myXts$Cash.at.end.of.period, lag = 1)/lag(myXts$Cash.at.end.of.period)*100,4)
  
  myXts$Capital.expenditures.Q = round(diff(myXts$Capital.expenditures, lag = 1)/lag(myXts$Capital.expenditures)*100,4)
  
  myXts$Price.Q = round(diff(myXts$Price, lag = 1)/lag(myXts$Price)*100,4)
  
  
  
  
  # Convert back to dataframe
  myData = data.frame(date = index(myXts), coredata(myXts))
  
  # drop unnecessary columns
  myData = myData[,-c(2:10,12:13)]
  myData = myData[, -which(names(myData) %in% c("Price"))]
  
  # get Y by shift Price.Q up 1 slot
  myData$Y = lead(myData$Price.Q)
  
  # get rid of first and last row which has NA
  myData = myData[complete.cases(myData),]
  
  outName <- strsplit(file.names[i],"_")[[1]][1]
  
  # output dataframe to csv
  write.csv(myData, file = paste0("../formatedData/",outName,".csv"))
  
  print(paste0("../formatedData/",outName,".csv"," Done!"))
}
  