labels=1:1:nBanks;
labels=labels';

approachesList2 = {'orig','anan','bara','hala','maxe'};
for a = approachesList2
    
    technique = a{:};
    
    % Compare the ordering of liquidtyRank importance
    outputMatrices.(technique).srank = horzcat(outputMatrices.(technique).sinkrank,labels);
    outputMatrices.(technique).srank = sortrows(outputMatrices.(technique).srank,-1);
    
    outputMatrices.(technique).stop1 = ismember(outputMatrices.orig.srank(1,2),outputMatrices.(technique).srank(1,2));
    outputMatrices.(technique).stop3 = ismember(outputMatrices.orig.srank(1,2),outputMatrices.(technique).srank(1:3,2));
    outputMatrices.(technique).scorr = corr(outputMatrices.orig.sinkrank,outputMatrices.(technique).sinkrank);
          
end


approachesList3 = {'batt','dreh','cimi'};
for a = approachesList3
    
    technique = a{:};
    
    ensembleN = size(outputMatrices.(technique).Network,3);
    
    for e = 1 : ensembleN
        
        % Compare the ordering of liquidtyRank importance
        outputMatrices.(technique).srank(:,:,e) = horzcat(outputMatrices.(technique).sinkrank(:,e),labels);
        outputMatrices.(technique).srank(:,:,e) = sortrows(outputMatrices.(technique).srank(:,:,e),-1);
        
        outputMatrices.(technique).stop1(e) = ismember(outputMatrices.orig.srank(1,2),outputMatrices.(technique).srank(1,2,e));
        outputMatrices.(technique).stop3(e) = ismember(outputMatrices.orig.srank(1,2),outputMatrices.(technique).srank(1:3,2,e));
        outputMatrices.(technique).scorr(e) = corr(outputMatrices.orig.sinkrank,outputMatrices.(technique).sinkrank(:,e));

    end
end

clear('ensembleN','approachesList3','approachesList2','a','technique','e');
