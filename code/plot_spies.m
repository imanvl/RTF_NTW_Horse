figure;
subplot(2,4,1)
spy(outputMatrices.orig.Network)
xlabel('')
title('Original')

subplot(2,4,2)
spy(outputMatrices.anan.Network)
xlabel('')
title('Anan')

subplot(2,4,3)
spy(+(sum(outputMatrices.cimi.Network(:,:,:),3)/size(outputMatrices.cimi.Network,3)>=0.5));
xlabel('')
title('Cimi')

subplot(2,4,4)
spy(outputMatrices.hala.Network)
xlabel('')
title('Hala')

subplot(2,4,5)
spy(+(sum(outputMatrices.batt.Network(:,:,:),3)/size(outputMatrices.batt.Network,3)>=0.5));
xlabel('')
title('Batt')   

subplot(2,4,6)
spy(outputMatrices.bara.Network)
xlabel('')
title('Bara')

subplot(2,4,7)
spy(+(sum(outputMatrices.dreh.Network(:,:,:),3)/size(outputMatrices.dreh.Network,3)>=0.5));
xlabel('')
title('Dreh')

subplot(2,4,8)
spy(outputMatrices.maxe.Network)
xlabel('')
title('Maxe')

%% 
filename = [pwd '\_results\', networkName, '_Spies.jpg'];
h = gcf;
saveas(h,filename,'jpg') 