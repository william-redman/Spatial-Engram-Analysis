%% Mouse #1 Trajectory
%   WTR 08/14/2018
%%
mouse_1_choices = zeros(21, 8);
for ii = 1:21
    error_diffs = abs(ref_memory_errors_mat(1, ii) - ref_memory_errors_mat(2:8, ii));
    [~, min_error_index] = min(error_diffs);
    
    mu_ii = animal_choices(ii, :, correspondence_vec(min_error_index + 1)); 
    diff_mat = zeros(7, 8);
    
    for jj = 1:7
        diff_mat(ii, :) = (animal_choices(ii, :, jj) - mu_ii).^2; 
    end
    
    sigma_ii = sqrt( sum(diff_mat) / 6);
    
    positions = floor(normrnd(mu_ii, sigma_ii)); 
    positions(find(positions > 10)) = 10; positions(find(positions < 0)) = 0;
    
    mouse_1_choices(ii, :) = positions;
    
end

animal_choices_2 = zeros(21, 8, 8);
animal_choices_2(:, :, 1:7) = animal_choices;
animal_choices_2(:, :, 8) = mouse_1_choices;
animal_choices = animal_choices_2;