% ANFIS validate individual csv
clear all;
clc;

files = dir('formatedData/IBM.csv');

fullpath = fullfile({files.folder},{files.name});

%%%%%%%%%%%%%%%%%%%%%%%%%% build the initial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Subtractive Clustering
genOpt = genfisOptions('SubtractiveClustering','ClusterInfluenceRange',0.6);% 0.6,0.7

%%%%%%FCM
%genOpt = genfisOptions('FCMClustering','FISType','sugeno');
%genOpt.NumClusters = 5;

rawdata = csvread(fullpath{1},1,2);

%single out data for test
train_input = rawdata(1:floor(size(rawdata,1)*0.6),1:22);
train_output = rawdata(1:floor(size(rawdata,1)*0.6), 23);

val_input = rawdata(floor(size(rawdata,1)*0.6):floor(size(rawdata,1)*0.8),1:22);
val_output = rawdata(floor(size(rawdata,1)*0.6):floor(size(rawdata,1)*0.8),23);

test_input = rawdata(floor(size(rawdata,1)*0.8):end,1:22);
test_output = rawdata(floor(size(rawdata,1)*0.8):end,23);


inFIS = genfis(train_input, train_output, genOpt);
init_model = anfisOptions('InitialFIS',inFIS,'EpochNumber',3,'DisplayANFISInformation',0);
init_model.ValidationData = [val_input val_output];

[fis, trainError, stepSize, chkFIS, chkError] = anfis([train_input train_output], init_model);

output = evalfis(test_input,fis);
rmse = sqrt(mean((output - test_output).^2))  % Root Mean Squared Error---Testing


csvwrite('test_output.csv',output)

