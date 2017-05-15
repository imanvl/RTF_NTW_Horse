labels=1:1:nBanks;
labels=labels';

approachesList2 = {'orig','anan','bara','hala','maxe'};
for a = approachesList2
    
    technique = a{:};
    
    % Compare the ordering of liquidtyRank importance
    outputMatrices.(technique).lrank = horzcat(outputMatrices.(technique).liquidityShortfall,labels);
    outputMatrices.(technique).lrank = sortrows(outputMatrices.(technique).lrank,-1);
    
    outputMatrices.(technique).ltop1 = ismember(outputMatrices.orig.lrank(1,2),outputMatrices.(technique).lrank(1,2));
    outputMatrices.(technique).ltop3 = ismember(outputMatrices.orig.lrank(1,2),outputMatrices.(technique).lrank(1:3,2));
    outputMatrices.(technique).lcorr = corr(outputMatrices.orig.liquidityShortfall,outputMatrices.(technique).liquidityShortfall);
    
end


approachesList3 = {'batt','dreh','cimi'};
for a = approachesList3
    
    technique = a{:};
    
    ensembleN = size(outputMatrices.(technique).Network,3);
    
    for e = 1 : ensembleN
        
        % Compare the ordering of liquidtyRank importance
        outputMatrices.(technique).lrank(:,:,e) = horzcat(outputMatrices.(technique).liquidityShortfall(:,e),labels);
        outputMatrices.(technique).lrank(:,:,e) = sortrows(outputMatrices.(technique).lrank(:,:,e),-1);
        
        outputMatrices.(technique).ltop1(e) = ismember(outputMatrices.orig.lrank(1,2),outputMatrices.(technique).lrank(1,2,e));
        outputMatrices.(technique).ltop3(e) = ismember(outputMatrices.orig.lrank(1,2),outputMatrices.(technique).lrank(1:3,2,e));
        outputMatrices.(technique).lcorr(e) = corr(outputMatrices.orig.liquidityShortfall,outputMatrices.(technique).liquidityShortfall(:,e));

    end
end

clear('ensembleN','approachesList3','approachesList2','a','technique','e');
