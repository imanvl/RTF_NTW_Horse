function SBM=simulate_AdM(inter_ba,intra_ba,n,n1,mincc,maxcc,mincp,maxcp,minpp,maxpp)

% function that returns a simulated adjacency matrix given the parameter values supplied in the sub gui
% inter_ba, intra_ba, n, n1, ,mincc,maxcc,mincp,maxcp,minpp,maxpp



for i=1:n1
    for j=1:n1
  %A(i,j)=rand*500000+500000;              % Core with exposures between mincc and maxcc
   SBM(i,j)=mincc+rand*(maxcc-mincc);
    end
end

for i=n1+1:n
    for j=1:n1
      %  A(j,i)=5000+rand*inter_ba;              % Core-periphery exposures between 0 and 5000
    SBM(i,j)=mincp+rand*(maxcp-mincp)+rand*inter_ba;
    end
end

for i=n1+1:n
    for j=n1+1:n
       % A(j,i)=rand*500;               % Periphery exposures between 0 and 500
    SBM(i,j)=minpp+rand*(maxpp-minpp);
    end
end


%A=ones(21,21);

for i=1:n
    SBM(i,i)=0;
end

for i=1:n
    for j=i+1:n
        SBM(i,j)=SBM(j,i)+rand*intra_ba;
    end
end