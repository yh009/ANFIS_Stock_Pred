% used for testing code
clear all;
clc;

data = csvread("anfis_test_output.csv");
[~,a] = sort(data,2,'descend');
[~,rank] = sort(a,2);



