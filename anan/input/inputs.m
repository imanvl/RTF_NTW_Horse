% SCALING PARAMETERS FOR PROBABILITIES
epsilon = 1e-4;
theta = 1;

% ANNEALING PARAMETERS (NO ANNEALING)
lambda = 1;
dlambda = 0;
annealingTime = 1;

% COST PARAMETERS
c = 0; %1/(max(totalInterbankAssets_vec)...
    %.* max(totalInterbankLiabilities_vec));
assetsPenalty_vec = ones(N,1)./(totalInterbankAssets_vec ...
    .* totalInterbankAssets_vec);
assetsPenalty_vec(isinf(assetsPenalty_vec)) = 1;

liabilitiesPenalty_vec = ones(N,1)./(totalInterbankLiabilities_vec ...
    .* totalInterbankLiabilities_vec);
liabilitiesPenalty_vec(isinf(liabilitiesPenalty_vec)) = 1;

% WE WANT TO ALLOCATE AT LEAST 99.99% OF ALL EXPOSURES 
stopVal = 0.0001 * sum(Assets);       % 99.99%%
stopIterations = N^2-N;    % Absolute upper bound since the matrix can only have N^2 - N links

%NUMBER OF MATRICES WE ATTEMPT TO ESTIMATE
draws = 1;