setwd("/Users/mac/Desktop/stockData/DJ30/originalData")

install.packages("corrplot")


library(dplyr)
library(xts)
library(data.table)
library(corrplot)



# clear environment
rm(list=ls())

# load data
rawdata = read.csv("CAT_quarterly_financial_data.csv")

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



##selectedData$Price.lead = lead(selectedData$Price, 1)

##### In order to do differecing easily, we need to transform the data frame into ts object ##NOT NEEDED ANYMORE


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

#Remove the 3rd col
# newXts = myXts[,-3]
#Remove cols with name
# set = c("Assets","Current.Assets")
# newXts = myXts[,-(which(colnames(myXts) %in% set))]

#Subseting by time
#subXts = window(myXts, start = "1995-01-01", end = "2018-01-01")

#calcChange = function(x, dataset = myXts, lagN = 1){
#  dataset$New = diff(x, lagN)
#  colnames(dataset$New) = paste(colnames(x), "lag", sep = ".")
#  return(dataset)
#}

#myXts = calcChange(myXts$Assets)

#ans = myXts[1:10]/lead(myXts[1:10],1) - 1

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


# Calculate correlation 
#myCor = cor(x=myData[,2:22], y=myData[,23])

#CAT_cor = cor(x=myData[,2:22], y=myData[,23])
#AAPL_cor = cor(x=myData[,2:22], y=myData[,23])
#F_cor = cor(x=myData[,2:22], y=myData[,23])
#IBM_cor = cor(x=myData[,2:22], y=myData[,23])

#myCor = round(cor(myData[,2:23]),4)
#corrplot(myCor, method="circle")

# Plot regession lines
#plot(myData$Price.Q,myData$Y)
#abline(lm(myData$Y ~ myData$Price.Q))


# output the correlation matrix
#write.csv(AAPL_cor, file = "CAT_car.csv")

# output dataframe to csv
write.csv(myData, file = "../formatedData/CAT.csv")

#myData[,22:34] = shift(.SD, 1) #not working


#zz <- merge(AAPL_cor, CAT_cor, by = "row.names", all = TRUE)
