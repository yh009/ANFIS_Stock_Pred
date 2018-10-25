# loop through files in folder for data preparation
# Update: 1. add back original P.B.ratio and Free.cash.flow.per.share
#         2. capped between 1996-01-01 and 2017-12-31
#         3. use na.aggregate to fill NA
#         4. at the end, replace all infinite value with zero

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
  djdata = read.csv("./DJIA/DJI.csv") # load DJIA
  
  # Rename SE to Book.value
  colnames(rawdata)[colnames(rawdata)=="Shareholders.equity"] <- "Book.value"
  colnames(djdata)[colnames(djdata)=="Close"] <- "DJIA" # rename DJIA close to DJIA
  
  # Drop columns (including date [1])
  selectedData = rawdata[, -which(names(rawdata) %in% 
                                    c("Shares", "Split.factor", "Non.controlling.interest","Preferred.equity","Goodwill...intangibles","Long.term.debt",
                                      "Earnings.available.for.common.stockholders","EPS.basic","EPS.diluted","Dividend.per.share",
                                      "ROE","ROA","Book.value.of.equity.per.share",
                                      "P.E.ratio","Cumulative.dividends.per.share","Dividend.payout.ratio","Long.term.debt.to.equity.ratio","Equity.to.assets.ratio","Net.margin","Asset.turnover"
                                    ))]
  ########selectedData = rawdata[,-c(2, 4, 10:13, 16:19, 29:31, 33:39)]
  djdata = djdata[,-c(2:4,6:7)] # delete unnecessary columnes of DJIA, leave only DJIA close
  
  # Reverse row order
  selectedData = arrange(selectedData, -row_number())
  
  # Replace all "None" with NA
  selectedData[,2:21] <- as.data.frame(lapply(selectedData[,2:21], function(x) {
    x <- as.character(x)
    x[x == "None"] <- NA
    as.numeric(x)
  }))
  
  ### Check the rows with NA manually
  
  
  
  # replace NA with aggregation
  date <- as.Date(selectedData$Quarter.end)
  myts <- xts(selectedData[,2:21],date)
  myts <- na.aggregate(myts,year)
  
  selectedData <- data.frame(date = index(myts), coredata(myts))
  
  # Omit rows with at least one NA
  selectedData = selectedData[complete.cases(selectedData),]
  
  
  
  # Add columns -- ROA, Net.margin, Asset.turnover, EPS, BPS, PE, PB
  selectedData$Net.margin = round((selectedData$Earnings / selectedData$Revenue)*100, digits = 4)
  
  selectedData$ROA = round(selectedData$Earnings / selectedData$Assets, digits = 4)
  
  selectedData$Asset.turnover = round(selectedData$Revenue / selectedData$Assets, digits = 4)
  
  selectedData$EPS = round(selectedData$Earnings / selectedData$Shares.split.adjusted, digits = 4)
  
  selectedData$PE = round(selectedData$Price / selectedData$EPS, digits = 4)
  
  # Divide the large values by 1000000
  selectedData[,c(3:15)] = round(selectedData[,c(3:15)] / 1000000, 1)
  
  
  # Move Price column to the end
  selectedData = selectedData[,c(setdiff(names(selectedData),c("Price")), c("Price"))]
  
  # Further drop columns by name
  selectedData = selectedData[, -which(names(selectedData) %in% c("Shares.split.adjusted", "Price.high", "Price.low"))]
  
  
  ### Before merging change date format to yearmon
  date = as.yearmon(as.character(selectedData$date))
  djDate = as.yearmon(as.character(djdata$Date))
  
  # # For AAPL
  # #date = as.Date(as.character(selectedData$Quarter.end),"%m/%d/%y")
  # # For others
  # date = as.Date(as.character(selectedData$Quarter.end),"%Y-%m-%d")
  # Create xts object
  myXts = xts(selectedData[,2:23], date)
  # colnames(myXts)
  
  # Create xts for DJIA
  # djDate = as.Date(as.character(djdata$Date),"%Y-%m-%d")
  myDJ = xts(djdata[,2],djDate)
  colnames(myDJ)<-"DJIA"
  
  
  
  # Merge stock data with DJIA data
  myXts = merge(myXts,myDJ)
  #Omit rows with NA
  myXts = myXts[complete.cases(myXts),]
  
  
  
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
  
  myXts$EPS.Q = round(diff(myXts$EPS, lag = 1)/lag(myXts$EPS)*100,4)
  
  myXts$Price.Q = round(diff(myXts$Price, lag = 1)/lag(myXts$Price)*100,4)
  
  myXts$DJIA.Q = round(diff(myXts$DJIA, lag = 1)/lag(myXts$DJIA)*100,4)
  
  # replace all infinite value with 0
  myXts[which(!is.finite(myXts))] <- 0
  
  # Convert back to dataframe
  myData = data.frame(date = index(myXts), coredata(myXts))
  
  # drop unnecessary columns
  myData = myData[,-c(2:14)]
  myData = myData[, -which(names(myData) %in% c("Price","DJIA"))]
  
  # get relative return
  myData$relativeReturn = myData$Price.Q - myData$DJIA.Q
  
  
  # get Y by shift Price.Q up 1 slot
  myData$Y = lead(myData$relativeReturn)
  
  # get rid of first and last row which has NA
  myData = myData[complete.cases(myData),]
  
  
  # Price.Q and DJIA.Q not needed anymore
  myData = myData[, -which(names(myData) %in% c("Price.Q","DJIA.Q"))]
  
  myData$fakeDate = as.Date(myData$date)
  
  # Subset from a begin time to and end time
  myDataFinal = myData[myData$fakeDate>=as.Date("1996-01-01") & myData$fakeDate<=as.Date("2017-12-31"),]
  
  myDataFinal = myDataFinal[, -which(names(myData) %in% c("fakeDate"))]
  
  print(nrow(myDataFinal))
  
  
  
  ###################### Unchanged
  outName <- strsplit(file.names[i],"_")[[1]][1]
  
  # output dataframe to csv
  write.csv(myDataFinal, file = paste0("../formatedData/",outName,".csv"))
  
  print(paste0("../formatedData/",outName,".csv"," Done!"))
}