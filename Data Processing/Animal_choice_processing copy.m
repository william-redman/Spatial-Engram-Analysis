%% Animal choice data processing
%   WTR 07/26/2018
%% 
animal_choice_mat = xlsread('ANIMAL CHOICES.xlsx');
animal_choice_mat(1, :) = [];
animal_choice_mat(:, 1:3) = [];
size_animal_choice_mat = size(animal_choice_mat); 
n_animals = 7;
n_trials = 5;
n_arms = 8;

animal_choices_1 = zeros(size_animal_choice_mat(1) / n_trials, n_arms); 

for ii = 1:(size_animal_choice_mat(1) / n_trials)
    animal_choice_block = animal_choice_mat((1 + (ii - 1) * n_trials):(5 + (ii - 1) * n_trials), :);
    
    accumulation_vec = zeros(1, n_arms);
    
    for jj = 1:n_trials
        for kk = 1:size_animal_choice_mat(2)
            if ~isnan(animal_choice_block(jj, kk))
                accumulation_vec(animal_choice_block(jj, kk)) = accumulation_vec(animal_choice_block(jj, kk)) + 1;
            end
        end
    end
    
    animal_choices_1(ii, :) = accumulation_vec;
    
end
    
animal_choices = zeros(21, 8, n_animals);

for ii = 1:n_animals
    animal_choices(:, :, ii) = animal_choices_1((1 + (ii - 1) * 21):(ii * 21), :);
end