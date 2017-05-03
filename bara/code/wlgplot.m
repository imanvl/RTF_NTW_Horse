function out=wlgplot(adjmat,XY,varargin)

sz=size(adjmat);
if(sz(1)~=sz(2))
    disp 'Matrix must be square!'; 
return;
end
n=sz(1);
sa=sum(adjmat');
sam=mean(sa);
s=mean(mean(adjmat));
for i=1:n
    for j=1:n
        if adjmat(i,j)>cell2mat(varargin)
        line([XY(i,1) XY(j,1)],[XY(i,2) XY(j,2)],'lineWidth',0.1+adjmat(i,j)/(5*s),'Marker','*','MarkerEdgeColor','r','MarkerSize',1+sa(i)/(0.5*sam));
        hold on;
        end
    end
end

hold off;