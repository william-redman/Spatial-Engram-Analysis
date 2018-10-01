%% Data processing 
%   WTR 06/17/2019
%%-----------------------------------------------------------------------%%
clear all
mouse_num = 3;

%% Reading the data from excel sheet
data = xlsread('RAW DATA CFOS.xlsx', mouse_num);

%% Trimming the data
data(1:2,:) = [];
data(:, 1) = [];

%% Finding the activity 
diff_values_mat = data(:, 3:4:52) - data(:, 1:4:52);
sigma = std(diff_values_mat(:));
threshold = 1.5 * sigma; 

activity_mat = zeros(size(diff_values_mat));
activity_mat(find(diff_values_mat >= threshold)) = 1;

%% Saving the data
save(strcat('mouse_', num2str(mouse_num), '_data'), 'data');
save(strcat('mouse_', num2str(mouse_num), '_activity'), 'activity_mat');