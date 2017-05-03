function [presentLinksList_vec,...
    absentLinksList_vec,...
    estimatedInterbank_mat,...
    convergedInd] = simulatedAnnealing_fun(...
    epsilon,...
    theta, ...
    c,...
    assetsPenalty_vec,...
    liabilitiesPenalty_vec, ...
    originalInterbank_mat,...
    totalInterbankAssets_vec,...
    totalInterbankLiabilities_vec, ...
    annealingParameter,...
    deltaAnnealingLevel,...
    annealingTime,...
    stopVal,...
    stopIterations)

% This function estimates an interbank network using information on the
% asset and liabilities marginals.
%=========================================================================
% Inputs
%   epsilon:
%           Probability for removing a link for the network
%
%   theta:
%           Scaling parameter for the probability of adding a link,
%           even if the "value" of the network with the link is lower
%           than the value without the link
%
%   c:
%           Penalty term in the value function for adding new links
%
%   assetsPenality_vec:
%           Penalty term for deviations from the asset marginals
%
%
%   liabilitiesPenality_vec:
%           Penalty term for deviations from the liabilities marginals
%
%   originalnterbank_mat:
%           Original interbank matrix
%
%   totalInterbankAssets_vec:
%           Total Interbank assets for each bank
%
%   totalInterbankLiabilities_vec:
%           Total interbank liabilities for each bank
%
%   annealingParameter:
%           Starting level for the fraction of the marginals to allocate
%           for a new link
%
%   deltaAnnealingLevel:
%           Increment for each iteration in the simulation for the change
%           in the annealing parameter
%
%   annealingTime:
%           Iteration where there is a jump in the annealing parameter
%
%   stopVal:
%           Stopping criteria for the total marginals
%
%   stopIteration:
%           Stopping criteria for the number of iteratons
%=========================================================================
% Outputs
%   presentLinks_vec:
%           List of links present in the estimated network
%
%    absentLinksList_vec:
%           List of links absent in the estimated network
%
%    estimatedInterbank_mat:
%           Estimated interbank network
%
%=========================================================================
%=========================================================================

% Number of banks
N = length(totalInterbankAssets_vec);

% Initializing the estimated interbank network
estimatedInterbank_mat = originalInterbank_mat;


% Interbank assets and liabilities deficits
interbankAssetsDeficit_mat = ...
    repmat(totalInterbankAssets_vec - ...
    sum(estimatedInterbank_mat, 2), 1, N);

interbankLiabilitiesDeficit_mat = ...
    repmat((totalInterbankLiabilities_vec - ...
    sum(estimatedInterbank_mat)')', N, 1);

% Links already present in the network
presentLinksList_vec = sparse(zeros(1,N^2));


absentLinksList_vec = sparse(...
    reshape(~eye(N), 1, N^2) .* ...
    ones(1, N^2) .* ...
    reshape(interbankAssetsDeficit_mat > 0, 1, N^2)) .* ...
    reshape(interbankLiabilitiesDeficit_mat > 0, 1, N^2);


% Prior probabilities for adding links
priorQ_vec = evaluatePriors_fun(...
    N, ...
    absentLinksList_vec,...
    interbankAssetsDeficit_mat,...
    interbankLiabilitiesDeficit_mat);

% Counter for the number of links that have been added to the network
linksAddedCounter = 0;

% Counter for the number of iterations that have passed
iteration = 0;

    
while sum(totalInterbankAssets_vec - sum(estimatedInterbank_mat, 2)) ...
        > stopVal && ...
        iteration < stopIterations && ...
        nnz(absentLinksList_vec) > 0
    
    iteration = iteration + 1;
    temp = rand;
    
    
    if temp <= epsilon
        % Remove link with probability epsilon
        
        linkOK = 0;
        while linkOK == 0
            % Sample the link for the list of existing links
            [~, removeLink] = datasample(presentLinksList_vec, 1);
        
            [linkRowPosition, linkColumnPosition] = ...
                ind2sub(N, removeLink);
            
            if linkRowPosition ~= linkColumnPosition
                linkOK = 1;
            end
        end
        
        estimatedInterbank_mat(linkRowPosition, ...
            linkColumnPosition) = 0;
        
        absentLinksList_vec(removeLink) = 1;
        presentLinksList_vec(removeLink) = 0;
    else
        % Else add a link with probability 1 - epsilon
        
        linkOK = 0;
        while linkOK == 0
            % Pick a link at random, with probability priorQ
            [~, addLink] = datasample(absentLinksList_vec, 1, ...
                'Weights', full(priorQ_vec));
        
            [linkRowPosition, linkColumnPosition] = ...
                ind2sub(N, addLink);
            if linkRowPosition ~= linkColumnPosition
                linkOK = 1;
            end
        end
        
        
        % Interbank matrix with the new link
        testInterbank_mat = estimatedInterbank_mat;
        
        testInterbank_mat...
            (linkRowPosition, linkColumnPosition) = ...
            annealingParameter ...
            * min(totalInterbankAssets_vec(linkRowPosition) ...
			 - sum(estimatedInterbank_mat(linkRowPosition,:)), ...
			 totalInterbankLiabilities_vec(linkColumnPosition)...
			 - sum(estimatedInterbank_mat(:,linkColumnPosition)));
        
        % Determine the value of the interbank network
        V_test = interbankNetworkValue_fun(c, assetsPenalty_vec, ...
            liabilitiesPenalty_vec, ...
            testInterbank_mat,...
            totalInterbankAssets_vec, ...
            totalInterbankLiabilities_vec);
        
        % The value of the "old" interbank network
        V = interbankNetworkValue_fun(c, assetsPenalty_vec, ...
            liabilitiesPenalty_vec, ...
            estimatedInterbank_mat,...
            totalInterbankAssets_vec, ...
            totalInterbankLiabilities_vec);
        
        rho = rand;
        % The new network is accepted whenever its value is greater than
        % the value of the old network. Otherwise, with probability rho
        % the new network is accepted.
        if V_test - V >= 0 ...
                || rho > exp(theta * (V - V_test))
            
            estimatedInterbank_mat = testInterbank_mat;
            
            absentLinksList_vec(addLink) = 0;
            presentLinksList_vec(addLink) = 1;
            
            % Increment the annealing parameter
            linksAddedCounter = linksAddedCounter + 1;
            
            if mod(iteration, annealingTime) == 0
                annealingParameter = min(annealingParameter ...
                    + deltaAnnealingLevel, 1);
            end
           
        else
            fprintf('link (%i, %i) not added:\n\t V_old %f > V_new %f\n',...
                linkRowPosition, linkColumnPosition, V, V_test);
        end
    end
    
    % Update the asset and liability marginals
    interbankAssetsDeficit_mat = ...
        repmat(totalInterbankAssets_vec - ...
        sum(estimatedInterbank_mat, 2), 1, N);
    
    interbankLiabilitiesDeficit_mat = ...
        repmat((totalInterbankLiabilities_vec - ...
        sum(estimatedInterbank_mat)')', N, 1);
    
    absentLinksList_vec = reshape(...
        reshape(absentLinksList_vec, N, N) .* ...
        (interbankAssetsDeficit_mat > 0) .* ...
        (interbankLiabilitiesDeficit_mat > 0), 1, N^2);
    
    
    % Update the priors with which we will select a new link in the next
    % iteration
    priorQ_vec = evaluatePriors_fun(...
        N, ...
        absentLinksList_vec, ...
        interbankAssetsDeficit_mat, ...
        interbankLiabilitiesDeficit_mat);

  
end

convergedInd = 0;
if sum(totalInterbankAssets_vec ...
        - sum(estimatedInterbank_mat, 2)) < stopVal
    fprintf('\n Target for allocation reached!\n\n');
    convergedInd = 1;
end

% REPORT:
% display('=======================================================')
% display(['Stopped at iteration: ',num2str(iteration)])
% display(['compared to target number of: ',num2str(stopIterations)])
% display(['Remaining links that could have been allocated: ',...
%     num2str(nnz(absentLinksList_vec))])

