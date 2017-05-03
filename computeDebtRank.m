labels=1:1:nBanks;
labels=labels';

approachesList2 = {'orig','anan','bara','hala','maxe'};
for a = approachesList2
    
    technique = a{:};
    
    % Compare the ordering of debtRank importance
    outputMatrices.(technique).drank = horzcat(outputMatrices.(technique).debtrank,labels);
    outputMatrices.(technique).drank = sortrows(outputMatrices.(technique).drank,-1);
    
    outputMatrices.(technique).dtop1 = ismember(outputMatrices.orig.drank(1,2),outputMatrices.(technique).drank(1,2));
    outputMatrices.(technique).dtop3 = ismember(outputMatrices.orig.drank(1,2),outputMatrices.(technique).drank(1:3,2));
    outputMatrices.(technique).dcorr = corr(outputMatrices.orig.debtrank,outputMatrices.(technique).debtrank);
    
end


approachesList3 = {'batt','dreh','cimi'};
for a = approachesList3
    
    technique = a{:};
    
    ensembleN = size(outputMatrices.(technique).Network,3);
    
    for e = 1 : ensembleN
        
        % Compare the ordering of debtRank importance
        outputMatrices.(technique).drank(:,:,e) = horzcat(outputMatrices.(technique).debtrank(:,e),labels);
        outputMatrices.(technique).drank(:,:,e) = sortrows(outputMatrices.(technique).drank(:,:,e),-1);
        
        outputMatrices.(technique).dtop1(e) = ismember(outputMatrices.orig.drank(1,2),outputMatrices.(technique).drank(1,2,e));
        outputMatrices.(technique).dtop3(e) = ismember(outputMatrices.orig.drank(1,2),outputMatrices.(technique).drank(1:3,2,e));
        outputMatrices.(technique).dcorr(e) = corr(outputMatrices.orig.debtrank,outputMatrices.(technique).debtrank(:,e));

    end
end

clear('DR','ib_assets','DR_loss');
clear('ensembleN','approachesList3','approachesList2','a','technique','e');
