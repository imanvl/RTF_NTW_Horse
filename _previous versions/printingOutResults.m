Output_filename = [pwd '\_results\Tables_Stats.xlsx'];%'Tables_Stats.xlsx';

    Table = {'orig','anan','bara','batt','dreh','mast2','maxe'};
    xlRange = 'B1';
    sheet = 'Stats';
    xlswrite(Output_filename,Table,sheet,xlRange)
    
    Table = {'Number of links';'Network density'; 'Mean degree'; ...
        'Median degree'; 'Assortativity'; 'Dependency lending'; ...
        'Dependency borrowing'; 'Local clustering'; 'Core size (% banks)';...
        'Error score(% links)'; 'Correlation'; 'Overlap1'; 'Overlap3'};
    xlRange = 'A2';
    sheet = 'Stats';
    xlswrite(Output_filename,Table,sheet,xlRange)
    
    approachesList = fieldnames(outputMatrices);
    list_measures  = fieldnames(outputMatrices.(approachesList{1}));
    
    list_measures1 = list_measures(2:11);
    list_measures2 = list_measures(16:18);
    list_measures = [list_measures1;list_measures2];
    
    nb_appr      = length(approachesList);
    nb_measures  = length(list_measures);
    
    a = ['B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'];
    b = [2:nb_measures+1]; 
    
    for i = 1:nb_appr
       
       for j = 1:nb_measures
        
           Table = median(outputMatrices.(approachesList{i}).(list_measures{j})); 
           xlRange = [a(i) num2str(b(j))];
           sheet = 'Stats';
           xlswrite(Output_filename,Table,sheet,xlRange) 
       end
    end
    
    
    
    Table = {'orig','anan','bara','batt','dreh','mast2','maxe'};
    xlRange = 'A1';
    sheet = 'AvgDebtRank';
    xlswrite(Output_filename,Table,sheet,xlRange)
    
    a2 = ['A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'];
    
    for i = 1:nb_appr      
           Table = median(outputMatrices.(approachesList{i}).debtrank,2); 
           xlRange = [a2(i) '2'];
           sheet = 'AvgDebtRank';
           xlswrite(Output_filename,Table,sheet,xlRange) 
    end
    
  
    
 
    Table = {'orig','anan','bara','batt','dreh','mast2','maxe'};
    xlRange = 'B1';
    sheet = 'Similarity';
    xlswrite(Output_filename,Table,sheet,xlRange)
    
    Table = {'Hamming';'Jaccard'; 'Cosine'; 'Jensen'};
    xlRange = 'A2';
    sheet = 'Similarity';
    xlswrite(Output_filename,Table,sheet,xlRange)
    
    approachesList = fieldnames(outputMatrices);
    list_sim = fieldnames(outputMatrices.(approachesList{1}).similarity);
    
    nb_appr = length(approachesList);
    nb_sim  = length(list_sim);
    
    a = ['B'; 'C'; 'D'; 'E'; 'F'; 'G';'H'];
    b = [2:nb_sim+1];
    
    for i = 1:nb_appr
       
       for j = 1:nb_sim
        
           Table = median(outputMatrices.(approachesList{i}).similarity.(list_sim{j}),2);
           xlRange = [a(i) num2str(b(j))];
           sheet = 'Similarity';
           xlswrite(Output_filename,Table,sheet,xlRange) 
       end
    end
    
