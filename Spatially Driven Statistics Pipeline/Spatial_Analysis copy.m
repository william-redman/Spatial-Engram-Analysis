function [ sim_activity_cell, rf_size_dist ] = Spatial_Analysis( animal_choices, activity_cell, ...
    correspondence_vec, n_mice, n_arms, n_days, days)
%% Spatial Analysis
%   With this function, we create the simulateda ctivity based on the
%   spatially driven model presented in our write-up. This simulated
%   activity is then fed into the same analysis pipeline as that with which
%   we use to analyze the real data. 
%   WTR 09/11/2018
%%-----------------------------------------------------------------------%%
%%-----------------------------------------------------------------------%%
%% Globals 
visits = animal_choices(days, :, :); % note that the dimensions here are (days) x (arms) x (mice)
   
%% Conditions to match
%   In this step, we compute the two conditions that we want to match our 
%   simulated activity with the real activity with: total number of neurons
%   that fire each day and the number of new neurons that fire each day
%   (i.e. neurons that haven't fired in any of the previous recorded days).
%   We implement this matching because the two parameters play a role in a
%   number of the measures we are interested in for our analyis (for 
%   instance, the similarity index obviously is affected by how many new
%   neurons fire each day, as well as how many total neurons fired). 

n_new_neurons_mat = zeros(n_mice, n_days);
n_total_neurons_mat = zeros(n_mice, n_days);
rf_size_dist = zeros(n_mice, n_arms);

for ii = 1:n_mice 
    activity = activity_cell{ii}; 
    identity_neurons_fired = [];
    
    for jj = 2:(n_days + 1)
        active_neurons = find(activity(:, jj) == 1)';
        n_total_neurons_mat(ii, (jj - 1)) = length(active_neurons); 
        n_new_neurons_mat(ii, (jj - 1)) = length(active_neurons) - ...
            length(intersect(active_neurons, identity_neurons_fired));
        identity_neurons_fired = [identity_neurons_fired, active_neurons];
        identity_neurons_fired = unique(identity_neurons_fired); 
    end
end

%% Running the model 
%   Now we actually run our model. See the write-up for more details. 
sim_activity_cell = cell(1, n_mice);

for ii = 1:n_mice
   sim_activity = zeros(size(activity_cell{ii})); %keeping the same number of neurons per mouse
   available_neural_pool = 1:length(activity_cell{ii}); %neurons whose receptive field hasn't been determined yet
   maze_arm_pools = cell(1, n_arms); %neurons whose receptive field has been determined to be one of the eight maze arms
   
    for jj = 1:n_days
        n_recruited = n_new_neurons_mat(ii, jj); %here is where we match the number of new neurons to the real data
        n_recalled = n_total_neurons_mat(ii, jj) - n_recruited; %here is where we match the number of total neurons to the real data
        
        arm_n_recruited = zeros(1, n_arms); 
        arm_n_recalled = zeros(1, n_arms); 
        weights_recruited = zeros(1, n_arms); %see write-up for explanation on these weights
        weights_recalled = zeros(1, n_arms); 
        
        for kk = 1:n_arms 
            % Finding the of neurons that are recruited and recalled 
            expectation_recruited = n_recruited * visits(jj, kk, correspondence_vec(ii)) ...
            / sum(visits(jj, :, correspondence_vec(ii))); %eq. 1 
            expectation_recalled =  n_recalled * visits(jj, kk, correspondence_vec(ii)) ...
            / sum(visits(jj, :, correspondence_vec(ii))); %eq. xx
        
            arm_n_recruited(kk) = ceil(expectation_recruited);          
            weights_recruited(kk) = ceil(expectation_recruited) - expectation_recruited; %eq. xx 
            arm_n_recalled(kk) = ceil(expectation_recalled);
            weights_recalled(kk) = ceil(expectation_recalled) - expectation_recalled; 
            
            % Making sure that we aren't recalling more neurons than have
            % given arm kk as its receptive field.
            if arm_n_recalled(kk) > length(maze_arm_pools{kk})               
                arm_n_recruited(kk) = arm_n_recruited(kk) + (arm_n_recalled(kk) - length(maze_arm_pools{kk})); 
                arm_n_recalled(kk) = length(maze_arm_pools{kk});
            end            
        end
        
        % Removing number of neurons that fired from arms until the number
        % of neurons is matched to the actual number of neurons that fired,
        % using the weights as computed above. 
        if (n_recruited - sum(arm_n_recruited)) < 0 
            remainder = sum(arm_n_recruited) - n_recruited;           
            for ll = 1:remainder
                index = randsample(n_arms, 1, 'true', weights_recruited); 
                
                % Making sure we don't remove too many neurons from each
                % arm and make the neurons go negative
                while (arm_n_recruited(index) - 1) < 0
                    index = randsample(n_arms, 1, 'true', weights_recruited);
                end
                arm_n_recruited(index) = arm_n_recruited(index) - 1; 
            end
        end
        
         if (n_recalled - sum(arm_n_recalled)) < 0 
            remainder = sum(arm_n_recalled) - n_recalled; 
            for ll = 1:remainder
                index = randsample(n_arms, 1, 'true', weights_recruited);
                while (arm_n_recalled(index) - 1) < 0
                    index = randsample(n_arms, 1, 'true', weights_recruited);
                end
                arm_n_recalled(index) = arm_n_recalled(index) - 1; 
            end 
        end
           
        for kk = 1:n_arms
            % Finding which neurons are recalled 
            shuffling = randperm(length(maze_arm_pools{kk}));
            neurons_shuffled = maze_arm_pools{kk}(shuffling);
            sim_activity(neurons_shuffled(1:arm_n_recalled(kk)), jj) = 1;
        
            % Finding which neurons are recruited 
            maze_arm_pools{kk} = [maze_arm_pools{kk}, available_neural_pool(1:arm_n_recruited(kk))];
            sim_activity(available_neural_pool(1:arm_n_recruited(kk)), jj) = 1;
            available_neural_pool(1:arm_n_recruited(kk)) = [];
        end
    end
    
    % This is adjusting for the fact that the way in which the real data is
    % organized with a habitutation day at the beginning, and we don't
    % model habituation, so we have to shift our simulated data one row
    % over. Hopefully will deal with this soon. 
    sim_activity(:, end) = [];
    sim_activity = [zeros(length(sim_activity), 1), sim_activity];
    sim_activity_cell{ii} = sim_activity;
    
    for jj = 1:n_arms
        rf_size_dist(ii, jj) = length(maze_arm_pools{jj}); 
    end
    
end

rf_size_dist = mean(rf_size_dist); 
     
end

