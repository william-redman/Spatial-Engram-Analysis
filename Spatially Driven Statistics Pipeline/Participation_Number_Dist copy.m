function [ participation_dist ] = Participation_Number_Dist( activity_cell, n_mice, n_days, n_neurons )
%% Participation Number Distribution 
%   This function computes the participation numbers of all the neurons in
%   the data set. 
%   WTR 09/06/2018
%%-----------------------------------------------------------------------%%
%%-----------------------------------------------------------------------%%
%% Globals  
participation_dist = zeros(1, n_neurons);
counter = 1;

%% Participation number dist
for ii = 1:n_mice
    activity_mat = activity_cell{ii};
    participation_num = sum(activity_mat(:, 2:(n_days + 1)), 2)';
    participation_dist(counter:(counter + length(activity_cell{ii}) - 1)) = participation_num; 
    counter = counter + length(activity_cell{ii}); 
end


