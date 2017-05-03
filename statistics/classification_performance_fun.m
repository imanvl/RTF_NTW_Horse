function [Sensibility_TruePos,Specificity_TrueNeg,FalsPos,FalsNeg,Accuracy] = classification_performance_fun(original,estimation)   
 
original_A=sign(original(:,:));
estimation_A=sign(estimation(:,:));
CM = confusionmat(original_A(:),estimation_A(:));
CM(1,1)=CM(1,1)-length(original_A); %take away zeros corresp. to the diagonal
 
P=length(original_A(original_A(:)>0)); %number of positives
N=length(original_A(original_A(:)==0))-length(original_A); %number of off-diagonal zeros
TN=CM(1,1); % No. of TrueNegatives
FN=CM(2,1); % No. of FalseNegatives
FP=CM(1,2); % No. of FalsePositives
TP=CM(2,2); % No. of TruePositives
 
Sensibility_TruePos=TP/P; %true positives rate
Specificity_TrueNeg=TN/N; %true negative rate
FalsPos=1-Specificity_TrueNeg; %false positive rate
FalsNeg=FN/P; %false negative rate
Accuracy=(TP+TN)/(P+N); %total accuracy