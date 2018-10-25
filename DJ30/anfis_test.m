% recursively generate ANFIS for each stock and output test output to csv
clear all;
clc;

files = dir('formatedData/*.csv');
fullpaths = fullfile({files.folder},{files.name});
numFiles = size(fullpaths,2);% get number of csv files

pred_outputs = zeros(19,numFiles);% holder for predicted output
real_outputs = zeros(19,numFiles);% holder for real output
%%%%%%%%%%%%%%%%%%%%%%%%%% build the initial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Subtractive Clustering
genOpt = genfisOptions('SubtractiveClustering','ClusterInfluenceRange',0.6);% 0.6,0.7

%%%%%%FCM
%genOpt = genfisOptions('FCMClustering','FISType','sugeno');
%genOpt.NumClusters = 5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:numFiles
    %read csv exclude col names and row dates
    rawdata = csvread(fullpaths{i},1,2);
    %single out data for test
    train_input = rawdata(1:floor(size(rawdata,1)*0.8),1:22);
    train_output = rawdata(1:floor(size(rawdata,1)*0.8), 23);
    test_input = rawdata(floor(size(rawdata,1)*0.8):end, 1:22);
    test_output = rawdata(floor(size(rawdata,1)*0.8):end, 23);
    
    %write real output to holder
    real_outputs(:,i) = test_output;
    
    %replace all Inf and -Inf with 0
    train_input(~isfinite(train_input))=0;
    test_input(~isfinite(test_input))=0;
    
    data = [train_input train_output];
    %%%%%%build fis%%%%%%%
    inFIS = genfis(train_input, train_output, genOpt);
    init_model = anfisOptions('InitialFIS',inFIS,'EpochNumber',1,'DisplayANFISInformation',0);
    %%%%%%%%%%%%%%%%%%%%%%%
    [fis, trainError]  = anfis([train_input train_output], init_model);
    
    pred_output = evalfis(test_input,fis);
    rmse = sqrt(mean((pred_output - test_output).^2))  % Root Mean Squared Error---Testing
    
    pred_outputs(:,i) = pred_output;
    
end
% output test outputs
csvwrite('anfis_test_output.csv',pred_outputs);
csvwrite('real_test_output.csv',real_outputs);

% output rank of test output
[~,a] = sort(pred_outputs,2,'descend');
[~,rank] = sort(a,2);
csvwrite('anfis_test_output_rank.csv',rank);

% output real rank of output
[~,b] = sort(real_outputs,2,'descend');
[~,rankR] = sort(b,2);
csvwrite('real_output_rank.csv',rankR);


