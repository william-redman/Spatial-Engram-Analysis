function [ r_squared, similarity_index_mat ] = Milczarek_Paper_Plots( ...
    activity_cell, ref_memory_errors_mat, n_mice, n_days)
%% Milczarek Paper Plots
%   This function calculates the values needed to plot two of the same 
%   figures as were present in Milczarek et al. Current Biology 2018: 3d 
%   and 4a. 
%   WTR 09/08/2018
%%-----------------------------------------------------------------------%%
%%-----------------------------------------------------------------------%%
%% Figure 3 D
% Here we compute the similarity index between all pair of activity on the
% days that were recorded from. See Milczarek et al. for details on
% similarity index. Note that we only care about the days that the mice
% were trained on, hence why we cut out all the other days. 
%%-----------------------------------------------------------------------%%
similarity_index_mat = zeros(n_days + 1, n_days + 1, n_mice);

for ii = 1:n_mice
    activity_mat = activity_cell{ii};
    
    for jj = 1:(n_days + 1)
        for kk = 1:(n_days + 1) 
            if kk >= jj
                C = length(intersect(find(activity_mat(:, jj) == 1), find(activity_mat(:, kk) == 1)));
                A = length(find(activity_mat(:, jj) == 1));
                B = length(find(activity_mat(:, kk) == 1));
                similarity_index_mat(kk, jj, ii) = C / (A + B - C); %similarity index
            end
        end
    end
    
end
%%-----------------------------------------------------------------------%%
%% Figure 4 A
% Here we compute the R^2 value of the linear regression on the difference
% in reference errors between day 19 and all the other training days, as a
% function of similarity index between the two days' activity. We compute
% this is two different ways. One is to take the regression over all the
% mice and all the days (marked as Method 1 below) and the other approach
% is to take the regression over the data from each mouse and then average
% the R^2 values together (marked as Method 2 below). See write-up for more 
% details. 
%%-----------------------------------------------------------------------%%
% % Method 1
% x = []; y = []; counter = 1;
% Method 2
x = zeros(n_mice, n_days - 1); 
y = zeros(n_mice, n_days - 1); 
r_squared_vec = zeros(1, n_mice);

for ii = 1:n_mice 
    for jj = 1:(n_days - 1)
%         % Method 1
%           x(counter) = similarity_index_mat(n_days + 1, jj + 1, ii);
%           y(counter) = ref_memory_errors_mat(ii, 19) - ref_memory_errors_mat(ii, (3 * (jj - 1)) + 1);
%           counter = counter + 1;
        % Method 2
        x(ii, jj) = similarity_index_mat(n_days + 1, jj + 1, ii); 
        y(ii, jj) = ref_memory_errors_mat(ii, 19) - ref_memory_errors_mat(ii, (3 * (jj - 1)) + 1);

    end
    % Method 2    
    [r_squared_vec(ii), ~, ~] = regression(x(ii, :), y(ii, :));
end

% % Method 1
% [r, ~, ~] = regression(x, y); 
% r_squared = r^2; 
% Method 2
r_squared = mean(r_squared_vec.^2); 
std_r_squared = std(r_squared_vec.^2); 
   
% Computing the mean, across the eight mice, similarity index matrix
similarity_index_mat = mean(similarity_index_mat, 3); 
%%-----------------------------------------------------------------------%%
end

