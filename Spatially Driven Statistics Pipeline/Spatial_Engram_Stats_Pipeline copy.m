%% Spatial Engram Stats Pipeline
%   WTR 08/31/2018
%%-----------------------------------------------------------------------%%

%%-----------------------------------------------------------------------%%
%% Globals
n_iterations = 1000; 
n_mice = 8;
n_arms = 8;
days = 1:3:19;
n_days = length(days);
n_neurons = 6229;

r_squared = zeros(1, n_iterations );
similarity_index_mat = zeros(n_days + 1, n_days + 1, n_iterations); 
participation_dist_mat = zeros(n_iterations, n_neurons); 
rf_size_dist_mat = zeros(n_iterations, n_arms); 

%% Running loop
for ii = 1:n_iterations
    % Running our spatial analysis on the data and getting the simulated
    % activity
    [ sim_activity_cell, rf_size_dist_mat(ii, :) ] = Spatial_Analysis( animal_choices, activity_cell, ...
    correspondence_vec, n_mice, n_arms, n_days, days);

    % Taking the simulated activity and running it through the same
    % analysis as was used in Milczarek et al. Figures 3D and 4A. 
    [ r_squared(ii), similarity_index_mat(:, :, ii) ] = Milczarek_Paper_Plots( ...
        sim_activity_cell, ref_memory_errors_mat, n_mice, n_days );
    
    % Participation number distribution 
    [ participation_dist_mat(ii, :) ] = Participation_Number_Dist( ...
        sim_activity_cell, n_mice, n_days, n_neurons );
    
end

%% Results 
% R^2 value with standard deviation 
sim_r_squared = mean(r_squared(:)) 
sigma = std(r_squared(:)) 

% Histogram of r-squared values
figure
histogram(r_squared(:));
xlabel('R^2 value');
%title('Distribution of R^2 values'); 

% Participation number distribution 
figure
histogram(participation_dist_mat(:), 'Normalization', 'probability'); 
xlabel('PN value');
%title('PN Distribution Simulated Activity'); 

% Similarity index analysis
mean_similarity_index = mean(similarity_index_mat, 3);
sigma_similarity_index = std(similarity_index_mat, [], 3);

% Histogram
figure
imagesc(mean_similarity_index); 

% Distribution of number of neurons with rf at each arm 
figure
errorbar(1:n_arms, mean(rf_size_dist_mat), std(rf_size_dist_mat), 'ko');
xlabel('Maze arm number'); ylabel('Number of neurons with given rf'); 


%% Actual data 
% Running the analysis on the real data
[ actual_r_squared, actual_similarity_index_mat ] = Milczarek_Paper_Plots( ... 
    activity_cell, ref_memory_errors_mat, n_mice, n_days);
    
[ actual_participation_dist ] = Participation_Number_Dist( activity_cell, n_mice, n_days, n_neurons );

% The actual r-squared value 
actual_r_squared

% Histogram of actual participation distribution 
figure
histogram(actual_participation_dist(:), 'Normalization', 'probability'); 
xlabel('PN value');
%title('PN Distribution Real Data'); 

% Similarity index analysis 
figure
actual_similarity_index_mat(:, 1) = 0;
imagesc(mean(actual_similarity_index_mat, 3)); 

%% Comapring the simulated data to the real data
% Finding the probability that the spatial model is able to catch the
% r-squared value
p = length(find(r_squared(:) >= actual_r_squared)) / n_iterations

% Plotting the similarity index heat map as a different way to display the 
% results. Actual values as a function of time 
figure
for ii = 2:n_days
    plot(days(1:(ii - 1)), actual_similarity_index_mat(ii + 1, 2:ii), 'o-', 'color', ...
        [(ii - 2) / (n_days - 2), 0, 1 - (ii - 2) / (n_days - 2)], 'LineWidth', ...
        1.5 ); hold on
    errorbar(days(1:(ii - 1)), mean_similarity_index(ii + 1, 2:ii), sigma_similarity_index(ii + 1, 2:ii), ...
        '*--', 'color', [(ii - 2) / (n_days - 2), 0, 1 - (ii - 2) / (n_days - 2)], ...
        'LineWidth', 1.5 ); hold on
end
xlabel('Day'); 
ylabel('Similairty index');
%title('Similarity index heat map plotted'); 

% Normalized actual values as a function of time 
figure
for ii = 2:n_days
    plot(days(1:ii - 1), actual_similarity_index_mat(ii + 1, 2:ii) / ...
        max(actual_similarity_index_mat(ii + 1, 2:ii)), 'o-', 'color', ...
        [(ii - 2) / (n_days - 2), 0, 1 - (ii - 2) / (n_days - 2)], 'LineWidth', ...
        1.5 ); hold on 
    errorbar(days(1:(ii - 1)), mean_similarity_index(ii + 1, 2:ii) / ...
        max(mean_similarity_index(ii + 1, 2:ii)), sigma_similarity_index(ii + 1, 2:ii) / ...
        max(mean_similarity_index(ii + 1, 2:ii)), '*--', 'color', ...
        [(ii - 2) / (n_days - 2), 0, 1 - (ii - 2) / (n_days - 2)], 'LineWidth', ...
        1.5 ); hold on
    
end

xlabel('Day');
ylabel('Normalized similairty index');
%title('Normalized similarity index heat map plotted'); 


