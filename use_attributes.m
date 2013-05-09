clc;

%%

Weights = ones(1,D);        % let Weights be the weights of the attributes
I = 2;                      % let I be the index of the first song
C_w = 1;                    % let C_w be the weight constant for multiplication
K_w = 10;                   % let K_w be the weight reduction factor. this is used to make sure that the magnitude of the weights remains checked

WeightMin = 0.01;           % let WeightMin be the minimum weight that can be assigned

ElementsPerGroup = 4;       % ElementsPerGroup be the number of elements per group
G = N/ElementsPerGroup;     % let G be the number of groups. MUST BE AN INTEGER

% similarity S is defined as cos(theta) - tan_inverse|distance|/(pi/2)
% this takes into account the direction of the vector as well as the
% magnitude (second term was added for that)

Dissimilarity = zeros(N,N);    % let Dissimilarity be the similarity measure matrix for the edges connecting songs   

Feedback = 1;              % let Feedback be a boolean representation of positive or negative user Feedback. in continuous form, -1 <= Feedback <= 1

Suggestions = 10;           % let Suggestions be the number of songs we will suggest (number of iterations of the algorithm
                            % let SuggesitonsList be the list of indices of suggested songs
SuggestionsList = zeros(1,Suggestions);            

TimesPlayed = ones(1,N);    % the number of times each song has been played (offset by 1 i.e. not set to 0 for divisibility)

% pheromone deposition is currently independent of value associated with
% the edge. this is for better control of the system.

Pheromone = zeros(1,N);     % pheromone deposits on songs which have been played
PhMax = 1;                  % maximum value of pheromone
Lambda = 0.1;               % let Lambda be the pheromone evaporation factor

SimilarityMin = 1;          % let SimilarityMin be the minimum similarity between two vectors. this is needed to avoid problems caused by negative values
            
%%

% testing measures

precision = 0;              % let precision be the fraction of songs suggested which are in context of the current song being played

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% play the selected song (corresponding to index I) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TimesPlayed(I) = TimesPlayed(I) + 1;

% deposit pheromone on Candidates(I)
Pheromone(I) = PhMax;

%%

%%%%%%%%%%%%%%%%%%%
% suggest song(s) %
%%%%%%%%%%%%%%%%%%%

suggestion_count = 1;

while(suggestion_count < (Suggestions+1))
        
    group_I = floor(I/ElementsPerGroup) + 1;
    highlight_2_index = I;

    highlight_1_indices = zeros(1,G);

    for i = 1:G

        if(i == group_I)
            highlight_1_indices(i) = I;
        else
                                    % iterate for all groups
            group_start_index = ((i-1)*ElementsPerGroup + 1);

            % select a random number between 1 and (ElementsPerGroup-1) and add to
            % base

            highlight_1_index =  group_start_index + randint(1,1,ElementsPerGroup);    
            highlight_1_indices(i) = highlight_1_index;    
        end

    end    
    %%
    
    %
    % initialize dissimilarity matrix
    %

    cumulative_dissimilarity = zeros(1,N);

    for i = 1:N
    
        % find out the group corresponding to elements I and i
        group_i = floor((i-1)/ElementsPerGroup) + 1;

        %
        % find out distace of I from its group (group_I) to highlight_1_index 
        %
    
        if(I == highlight_1_indices(group_I))
            cumulative_dissimilarity(i) = cumulative_dissimilarity(i) + 0;
        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                            % vectors taken for element I and Candidates(i)
            vector_1 = Attributes(I,:);
            vector_2 = Attributes(highlight_1_indices(group_I),:);

            cos_theta = dot(vector_1, vector_2)/(norm(vector_1)*norm(vector_2));

            % distance is weighted euclidian distance

                            % vector_diff_sq will only contain positive values
            vector_diff_sq = (vector_1 - vector_2).^2;
            distance = sqrt(sum(vector_diff_sq.*Weights));

            % now calculate similarity
            vector_similarity = cos_theta - (atan(distance)/(pi/2));
            cumulative_dissimilarity(i) = cumulative_dissimilarity(i) + 1/(vector_similarity + SimilarityMin);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end

        %
        % find out distace of i from its group (group_i) to highlight_1_index 
        %
    
        if(i == highlight_1_indices(group_i))
            cumulative_dissimilarity = cumulative_dissimilarity + 0;
        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                            % vectors taken for element I and Candidates(i)
            vector_1 = Attributes(i,:);
            vector_2 = Attributes(highlight_1_indices(group_i),:);

            cos_theta = dot(vector_1, vector_2)/(norm(vector_1)*norm(vector_2));

            % distance is weighted euclidian distance

                            % vector_diff_sq will only contain positive values
            vector_diff_sq = (vector_1 - vector_2).^2;
            distance = sqrt(sum(vector_diff_sq.*Weights));

            % now calculate similarity
            vector_similarity = cos_theta - (atan(distance)/(pi/2));
            cumulative_dissimilarity(i) = cumulative_dissimilarity(i) + 1/(vector_similarity + SimilarityMin);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end

        %
        % find out distance of group_I to highlight 2 index
        %
        
        if(highlight_1_indices(group_I) == highlight_2_index)
            cumulative_dissimilarity = cumulative_dissimilarity + 0;
        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                            % vectors taken for element I and Candidates(i)
            vector_1 = Attributes(highlight_1_indices(group_I),:);
            vector_2 = Attributes(highlight_2_index,:);

            cos_theta = dot(vector_1, vector_2)/(norm(vector_1)*norm(vector_2));

            % distance is weighted euclidian distance

                            % vector_diff_sq will only contain positive values
            vector_diff_sq = (vector_1 - vector_2).^2;
            distance = sqrt(sum(vector_diff_sq.*Weights));

            % now calculate similarity
            vector_similarity = cos_theta - (atan(distance)/(pi/2));
            cumulative_dissimilarity(i) = cumulative_dissimilarity(i) + 1/(vector_similarity + SimilarityMin);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
        %
        % find out distance of group_i to highlight 2 index
        %
        
        if(highlight_1_indices(group_i) == highlight_2_index)
            cumulative_dissimilarity = cumulative_dissimilarity + 0;
        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                            % vectors taken for element I and Candidates(i)
            vector_1 = Attributes(highlight_1_indices(group_i),:);
            vector_2 = Attributes(highlight_2_index,:);

            cos_theta = dot(vector_1, vector_2)/(norm(vector_1)*norm(vector_2));

            % distance is weighted euclidian distance

                            % vector_diff_sq will only contain positive values
            vector_diff_sq = (vector_1 - vector_2).^2;
            distance = sqrt(sum(vector_diff_sq.*Weights));

            % now calculate similarity
            vector_similarity = cos_theta - (atan(distance)/(pi/2));
            cumulative_dissimilarity(i) = cumulative_dissimilarity(i) + 1/(vector_similarity + SimilarityMin);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
    end
    
    cumulative_dissimilarity = cumulative_dissimilarity/sum(cumulative_dissimilarity);
    cumulative_dissimilarity(I) = Inf;    

    %%
    
    pheromone_contribution = (PhMax - Pheromone)./TimesPlayed;
                                % since we are using dissimilarity, we
                                % divide instead of multiplying
    pheromonized_cumulative_dissimilarity  = cumulative_dissimilarity./pheromone_contribution;
    
    % get the index corresponding to the maximum similarity and suggest that
    % song
                                % index is relative only to the vector of similarity vector (not actual values of candidates)
    best_dissimilarity_index = find(pheromonized_cumulative_dissimilarity == min(pheromonized_cumulative_dissimilarity));  
                                % in case it is an array, we take the first element
    best_dissimilarity_index = best_dissimilarity_index(1);
    % CLUSTER GROUP. NOT DUBEY GROUP. DO NOT CONFUSE HERE.
    cluster_I = find(result.data.f(I,:) == max(result.data.f(I,:)));

    %%%%%%%%%%%%%%%%% DEBUG INFORMATION %%%%%%%%%%%%%%%%%%
    best_dissimilarity_index
    result.data.f(best_dissimilarity_index,cluster_I)
    %%%%%%%%%%%%%%%%% DEBUG INFORMATION %%%%%%%%%%%%%%%%%%
    
    %%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % play the selected song (corresponding to index Candidates(best_similarity_index)) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TimesPlayed(best_dissimilarity_index) = TimesPlayed(best_dissimilarity_index) + 1;
    
    % deposit pheromone on Candidates(best_similarity_index)
    Pheromone(best_dissimilarity_index) = PhMax;
    
    %%
    
    % take feedback
    if(result.data.f(best_dissimilarity_index,cluster_I) > 0.5)
        Feedback = 1;
        precision = precision + 1;
        
        % move to that song
        I = best_dissimilarity_index;
    else
        Feedback = -1;
    end
    
    %%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % modify weights based on Feedback %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    attribute_distances = Attributes;

    for i = 1:N
        attribute_distances(i,:) = abs(attribute_distances(i,:) - attribute_distances(I,:));
    end

    attribute_distances_avg = sum(attribute_distances)*(1/N);

    attribute_distances_selected = abs(attribute_distances(best_dissimilarity_index,:) - attribute_distances(I,:));

    % now recaliberate the weights

    % if the selected song got positive Feedback
    % if d_s < d_i (i.e. correct is closer) => w increases
    % w = w + C_w*(d_a - d_s)

    % if the selected song got negative Feedback
    % if d_s < d_i (i.e. incorrect is closer) => w decreases
    % w = w - C_w*(d_a - d_s)

    % Weights = Weights + C_w*Feedback*(attribute_distances_avg - attribute_distances_selected);

    if(Feedback == 1)
        Weights = Weights + C_w*(attribute_distances_avg - attribute_distances_selected);
                                    % make all values positive
        Weights = Weights - min(Weights) + WeightMin;
    else
        Weights = Weights - C_w*(attribute_distances_avg - attribute_distances_selected);
                                    % make all values positive
        Weights = Weights - min(Weights) + WeightMin;
    end

    % reduce the weights to smaller values
    Weights = Weights/K_w;

    %%
    
    %%%%%%%%%%%%%%%%%%%%
    % modify Pheromone %
    %%%%%%%%%%%%%%%%%%%%

    %
    % evaporate pheromone from all edges
    %
    
    Pheromone = Pheromone*exp(-Lambda);

    %%
    
    % one suggestion iteration completed    
    SuggestionsList(suggestion_count) = best_dissimilarity_index;
    suggestion_count = suggestion_count + 1;
end

precision = precision/Suggestions;
precision
