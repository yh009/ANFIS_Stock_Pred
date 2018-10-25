% Processing to model outputs to get relative return

clear all;
clc;

% load needed data
pred_rank = csvread("anfis_test_output_rank.csv");
real_return = csvread("real_test_output.csv");

% mean real return for comparison
mean_real_return = mean(real_return,2);
% write mean quarterly real return
csvwrite("mean_real_return.csv",mean_real_return);
mean_real = mean(mean_real_return)

% extract top 3/5/7/10 from predicted rank
%pred_rank(pred_rank>10)=0;
%pred_rank(pred_rank~=0)=1;


% extract below 3/5/7/10 from predicted rank
pred_rank(pred_rank<13)=0;
pred_rank(pred_rank~=0)=1;

% get top picks' real return
picked_return = real_return .* pred_rank;

% sum each row to get portfolio return
port_return = mean(picked_return,2);

% output port_return
csvwrite('port_return_b10.csv',port_return);

% mean of quarterly portfolio return
mean_return = mean(port_return)
