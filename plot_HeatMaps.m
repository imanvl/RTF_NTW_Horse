figure
colormap('Hot')

subplot(2,4,1)
imagesc(outputMatrices.orig.Network)
title('Original')

subplot(2,4,2)
imagesc(outputMatrices.anan.Network)
title('Anan')

subplot(2,4,3)
imagesc(sum(outputMatrices.cimi.Network(:,:,:),3)/size(outputMatrices.cimi.Network,3));
title('Cimi')

subplot(2,4,4)
imagesc(outputMatrices.hala.Network)
title('Hala')

subplot(2,4,5)
imagesc(sum(outputMatrices.batt.Network(:,:,:),3)/size(outputMatrices.batt.Network,3));
title('Batt')   

subplot(2,4,6)
imagesc(outputMatrices.bara.Network)
title('Bara')

subplot(2,4,7)
imagesc(sum(outputMatrices.dreh.Network(:,:,:),3)/size(outputMatrices.dreh.Network,3));
title('Dreh')

subplot(2,4,8)
imagesc(outputMatrices.maxe.Network)
title('Maxe')
filename = [pwd '\_results\', networkName, '_HeatMaps.jpg'];
h = gcf;
saveas(h,filename,'jpg') 