
% Define similarly function to compare matricies
% Compares adjcency matrices only
hamming_dist = @(a,b)sum(1*(a(:)>0)~=1*(b(:)>0));
jaccard_dist = @(a,b)sum(a(:) & b(:))/ sum(a(:) | b(:));

% Compares valued networks
cosine_simi = @(a,b)dot(a(:),b(:))/(sqrt(dot(a(:),a(:)))*sqrt(dot(b(:),b(:))));
% For the Jensen Shannon distance we have the function jsdiv(a,b)

approachesList2 = {'orig','anan','bara','hala','maxe'};
for a = approachesList2
    
    technique = a{:};
        
    % Compute similarity measures
    vectorizedEstimatedNetwork = outputMatrices.(technique).Network(:);
    vectorizedEstimatedNetwork(isnan(vectorizedEstimatedNetwork) | isinf(vectorizedEstimatedNetwork)) = 0;
    
    outputMatrices.(technique).similarity.hamming = hamming_dist(outputMatrices.orig.Network(:), vectorizedEstimatedNetwork);
    outputMatrices.(technique).similarity.jaccard = jaccard_dist(outputMatrices.orig.Network(:), vectorizedEstimatedNetwork);
    outputMatrices.(technique).similarity.cosine  = cosine_simi(outputMatrices.orig.Network(:), vectorizedEstimatedNetwork);
    outputMatrices.(technique).similarity.jensen  = jsdiv(outputMatrices.orig.Network(:) / sum(outputMatrices.orig.Network(:)), ...
        vectorizedEstimatedNetwork / sum(vectorizedEstimatedNetwork));
    
    
    % Compute confusion matrix
    [truePositives,...
        trueNegatives,...
        falsePositives,...
        falseNegatives,...
        accuracy] = classification_performance_fun(outputMatrices.orig.Network,outputMatrices.(technique).Network);
    
    outputMatrices.(technique).confusionMatrix.truePositives = truePositives;
    outputMatrices.(technique).confusionMatrix.trueNegatives = trueNegatives;
    outputMatrices.(technique).confusionMatrix.falsePositives = falsePositives;
    outputMatrices.(technique).confusionMatrix.falseNegatives = falseNegatives;
    outputMatrices.(technique).confusionMatrix.accuracy = accuracy;
       
end


approachesList3 = {'batt','dreh','cimi'};
for a = approachesList3
    
    technique = a{:};
    
    ensembleN = size(outputMatrices.(technique).Network,3);
    
    for e = 1 : ensembleN
        
        % Compute similarity measures
        vectorizedEstimatedNetwork = reshape(outputMatrices.(technique).Network(:,:,e), nBanks^2, 1);
        vectorizedEstimatedNetwork(isnan(vectorizedEstimatedNetwork) | isinf(vectorizedEstimatedNetwork)) = 0;
        
        outputMatrices.(technique).similarity.hamming(e) = hamming_dist(outputMatrices.orig.Network(:), vectorizedEstimatedNetwork);
        outputMatrices.(technique).similarity.jaccard(e) = jaccard_dist(outputMatrices.orig.Network(:), vectorizedEstimatedNetwork);
        outputMatrices.(technique).similarity.cosine(e)  = cosine_simi(outputMatrices.orig.Network(:), vectorizedEstimatedNetwork);
        outputMatrices.(technique).similarity.jensen(e)  = jsdiv(outputMatrices.orig.Network(:) / sum(outputMatrices.orig.Network(:)), ...
            vectorizedEstimatedNetwork / sum(vectorizedEstimatedNetwork));
        
        % Compute confusion matrix
        [truePositives, trueNegatives, falsePositives, falseNegatives,...
            accuracy] = classification_performance_fun(outputMatrices.orig.Network,outputMatrices.(technique).Network(:,:,e));
        
        outputMatrices.(technique).confusionMatrix.truePositives(e) = truePositives;
        outputMatrices.(technique).confusionMatrix.trueNegatives(e) = trueNegatives;
        outputMatrices.(technique).confusionMatrix.falsePositives(e) = falsePositives;
        outputMatrices.(technique).confusionMatrix.falseNegatives(e) = falseNegatives;
        outputMatrices.(technique).confusionMatrix.accuracy(e) = accuracy;

    end
end

clear('truePositives','trueNegatives','falsePositives','falseNegatives','accuracy');
clear('vectorizedEstimatedNetwork','labels','ensembleN','approachesList3',...
    'approachesList2','a','technique','e');