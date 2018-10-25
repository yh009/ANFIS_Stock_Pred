% Anfis validation using exp_window
clear all;
clc;

files = dir('formatedData/*.csv');
fullpaths = fullfile({files.folder},{files.name});
numFiles = size(fullpaths,2);% get number of csv files

num_win = 5;

% initalize empty array to hold validation error/std from each csv
val_err = zeros(1,numFiles);
val_std = zeros(1,numFiles);

%%%%%%%%%%%%%%%%%%%%%%%%%% build the initial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Subtractive Clustering
genOpt = genfisOptions('SubtractiveClustering','ClusterInfluenceRange',0.6);

%%%%%%FCM
%genOpt = genfisOptions('FCMClustering','FISType','sugeno');
%genOpt.NumClusters = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%% build the initial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Looping through csv and do validation on each
for i = 1:numFiles
    %read csv exclude col names and row dates
    rawdata = csvread(fullpaths{i},1,2);
    %single out data for test
    train_input = rawdata(1:floor(size(rawdata,1)*0.8),1:22);
    train_output = rawdata(1:floor(size(rawdata,1)*0.8), 23);
    data = [train_input train_output];
    %%%%%%build fis%%%%%%%
    inFIS = genfis(train_input, train_output, genOpt);
    init_model = anfisOptions('InitialFIS',inFIS,'EpochNumber',1,'DisplayANFISInformation',0);
    %%%%%%%%%%%%%%%%%%%%%%%
    
    [err, std] = exp_window(data,init_model, num_win); 
    val_err(i)=err;
    val_std(i)=std;
    disp(err);
end

mean(val_err)

