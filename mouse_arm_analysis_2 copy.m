%% Maze Arm Pair Analysis 2
%   WTR 09/28/2018 
%   This script is written to analyze whether there is a bias as to
%   couplets of maze arms in the mices' trajectories. Just like the first
%   script but cleaner and plots differences as a function of time. 
%%-----------------------------------------------------------------------%%
%%-----------------------------------------------------------------------%%
%% Processing the data
animal_choice_mat = xlsread('ANIMAL CHOICES.xlsx'); %reading in the data
animal_choice_mat(1, :) = []; %cleaning it of non-important rows and columns
animal_choice_mat(:, 1:3) = [];

size_animal_choice_mat = size(animal_choice_mat); 
n_animals = 7;
n_trials = 5;
n_arms = 8;
max_tries = 8;
n_days = 21;

mouse_choices = zeros(n_trials * n_days, max_tries, n_animals); 

for ii = 0:(n_animals - 1)
    mouse_choices(:, :, ii + 1) = animal_choice_mat((ii * n_trials * n_days + 1):((ii + 1) * n_trials * n_days), :);
end

%% Counting combination pairs 
couplet_count_mat = zeros(n_arms, n_arms, n_animals); 
rel_diff_time_mat = zeros(n_arms, n_arms, n_days, n_animals); 

for ii = 1:n_animals 
    for jj = 1:(n_trials * n_days)
        for kk = 1:(max_tries - 1)
            if ~isnan(mouse_choices(jj, kk, ii)) && ~isnan(mouse_choices(jj, kk + 1, ii))
                couplet_count_mat(mouse_choices(jj, kk, ii), mouse_choices(jj, kk + 1, ii), ii) = ...
                    couplet_count_mat(mouse_choices(jj, kk, ii), mouse_choices(jj, kk + 1, ii), ii) + 1; 
            end
        end   
    
        if floor(jj / n_trials) == (jj / n_trials)
            for kk = 1:n_arms
                rel_diff_time_mat(kk, :, jj/n_trials, ii ) = ...
                    (couplet_count_mat(kk, :, ii) - couplet_count_mat(:, kk, ii)') ...
                    ./ (couplet_count_mat(kk, :, ii) + couplet_count_mat(:, kk, ii)');
                rel_diff_time_mat(kk, kk, jj/n_trials, ii) = nan;
            end
        end
    end
               
end

%% Plotting
% Histogram of relative difference 
figure
histogram(rel_diff_time_mat(:, :, n_days, :), -1.1:0.2:1.1);%, 'Normalization', 'probability');
xlabel('Relative difference in occurence'); ylabel('Percent of total counts'); 

% Plotting time dependence of largest relativie difference pairs 
figure

for ii = 1:n_animals 
    pairs_of_interest = find(rel_diff_time_mat(:, :, n_days, ii) >= 1/3);
    relevant_diffs = zeros(n_days, length(pairs_of_interest)); 
    
    for jj = 1:n_days 
        rel_diff_day_jj_mat = rel_diff_time_mat(:, :, jj, ii);
        relevant_diffs(jj, :) = rel_diff_day_jj_mat(pairs_of_interest)';
    end
    
    for jj = 1:length(pairs_of_interest)
        errorbar(1:n_days, mean(relevant_diffs ,2) , std(relevant_diffs, [], 2), 'ko-', 'LineWidth', 1.5); hold on
    end
end

xlabel('Day'); ylabel('Mean relative difference'); 