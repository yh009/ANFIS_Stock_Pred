% Expanding window validation

function [val_score, val_std] = exp_window(data, init_model, num_win)
% data - must exclude test data reserved for testing
% num_win - number of windows
% Assumption: Y is the last col
numC = size(data,2);
numR = size(data,1);
init_train = 0.5;
interval = (1-init_train)/num_win;
scoreboard = zeros(1,num_win);

for i = 1:num_win
    train_input = data(1:floor(numR*(init_train+interval*(i-1))),1:(numC-1));
    train_output = data(1:floor(numR*(init_train+interval*(i-1))),numC);
    val_input = data(floor(numR*(init_train+interval*(i-1))):floor(numR*(init_train+interval*i)),1:(numC-1));
    val_output= data(floor(numR*(init_train+interval*(i-1))):floor(numR*(init_train+interval*i)),numC);
    
    % for ANFIS
    init_model.ValidationData = [val_input val_output];% define tha val data for FIS
    [fis, trainError, stepSize, chkFIS, chkError] = anfis([train_input train_output], init_model);
    scoreboard(i) = chkError(end);   
end



val_score = mean(scoreboard);
val_std = std(scoreboard);

end