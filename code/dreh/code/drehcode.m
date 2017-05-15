function [M_out]=drehcode(Assets,Liabilities, Density, Ensemble)
%
% Estimates randomized interbank matrixes and imposing random zero
% restrictions off the diagonal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Based on ras.m by Christian Upper, extended by Goetz von Peter, and
% Mathias Drehmann. Adapted for the RTF LST by Iman van Lelyveld
%
% Improvements Mathias:
% Can create sink bank if total interbank deposits are not equal to total 
% interbank assets for banks in systemic (here crucial that r assets and 
% c liabilities) randomized interlinkages
%
% Used in Nikola Tarashev & Mathias Drehmann, 2011 
% "Measuring the systemic importance of interconnected banks," 
% BIS Working Papers 342
%
% Building on entropy_rand_0 in     \orgiinal_code 
%
% Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mat: 
% -------------------------------------------------------------------------
% 3 dimensional matrix. First 2 dimensions interbank matrix, third 
% dimension Nrand+1 interbank matrices. Mat(:,:,1) is maximum 
% entropy solution, remaining Nrand matrixes are randomized 
%
% Mat is 2 rows\columns larger than asset and liab vector becasue of
% a) sink bank and b) contains row and column sum at end
% for example
% row sum for rows 1:N+1 (where N number of banks) for first column
% equals  total interbank assets of banks 1, where rows 2:N provide
% assets vis-a-vie bank 2 to N, row N+1 is asset to sink bank
% column sum over columns 1:N+1 (where N number of banks) for first row 
% equals total  interbank liabilities of banks 1, where column 2:N provide
% liabilities vis-a-vie bank 2 to N, column N+1 is liab to sink bank
%
% Eval
% -------------------------------------------------------------------------
% provides different measures of difference between random solution
% and ME solution
% 1. column simulation number
% 2. col norm of matrix -ME solution
% 3. col for sum of rel difference between matrix and ME (ME base case)
% 4. col number of zeros off the diagonal.
% 5. col is 0 if convergence, otherwise 100
%
% Input
% -------------------------------------------------------------------------
% 5 inputs in total: Assets,Liabilities,Nrand,S,U
% Assets:          Vector of total interbank assets per bank
% Liabilities:     Vector of total interbank liabilities per bank
%             Entering a single matrix will assign its sums to these vectors
%             Vectors can differ in length: non-square matrices are permitted
%             Entropy is maximised w.r.t flat prior but with zero diagonal.
% Nrand:    Number of random simulations for matrix
%
% Optional:  
% S:        Allows to create a sink bank if S=1
% U:        Allows to (here sink bank is not considered)
%           - enforce absolute entropy: entropy(r,c,ones(length(r),length(c)))
%           or
%           - refine relative entropy: specify an a priori matrix U.


%% Setting
Nrand =  Ensemble;                                                                % IvL
S     = 0;
I=1000;   % Maximum number of iterations
Min=0;   % if random number below Min, counterparty exposure between banks
         % is set to 0.

%%  ============= Checking inputs =============
% Single matrix



% Two vectors
% r and c not ideal but orignially coded this way so kept
% IVL: CHECK: ARE THE ROW/LIAB IN THE RIGHT ORDER

r=Assets';
c=Liabilities;

%r=Liabilities; 
%Assets = Assets';
%c=Assets;                                 % makes inputs column vectors
if min([r;c])<0
    error('elements in r and c have to be non-negative')
end


if (S==1)                     % Creating the sink bank
disp('Sink bank created')

    if (sum(c)>sum(r))
        disp('Interbank Liabilities smaller than interbank assets')
        r=[r ; (sum(c)-sum(r))];
        c=[c ;0];
    end
    if (sum(c)<sum(r))
         disp('Interbank Liabilities larger than interbank assets')
         c=[c ; (sum(r)-sum(c))];
        r=[r ;0];
    end
end



k1=sum(r); k2=sum(c);                           % totals
r=r/k1; c=c/k2; T=(k1+k2)/2;                    % scale by totals


rows=length(r); cols=length(c); 
if rows*cols== rows+cols+min(rows,cols)
        warndlg('Zero degrees of freedom: exact solution rather than estimation.', '!! WARNING !!')
        X=entropy_exact(r,c);
elseif rows*cols<rows+cols+min(rows,cols)
    warndlg('Inconsistent system: too few dimensions.', '!! WARNING !!')
    error
end

% 5 arguments
if (nargin==5) & (size(U)~=[rows cols])
        error('U disagrees with dimensions of rows, columns.')
end






%% ============= Prior: absolute or relative =============
if nargin == 5
    X=U./T;                                     % RELATIVE: use a prior matrix U, scaled down.
    disp('Relative entropy maximisation')
else

    EX=r*c';                                     % ABSOLUTE: outer product as initial guess (faster but equivalent to flat prior)
    U=triu(EX, +1);                              % set diagonal to 0
    L=tril(EX, -1);
    EX=U+L;
    %disp('Absolute entropy maximisation (plus zero-diagonal restriction)')
end

%% ==Randomizing and creating IB matrix

% initializing
Mat=zeros(size(r,1)+1, size(c,1)+1, Nrand+1);
Eval=zeros(Nrand+1,5);


for tt=1:Nrand+1 
    

    
    if tt==1
        X=EX;           %Maximum entropy solution 
    else
        R=2*rand(size(r,1), size(c,1));
        temp = find(R<=Min);
        R(temp)=0;
        X=EX.*R;        % Randomize prior so that on average prior is equal to max entropy
    end
    
    
    %============= RAS-Algorithm =============

    indrow=find(sum(X')>0); m=length(indrow);       % indices of positive row sums (to apply method only to pos entries)
    indcol=find(sum(X)>0); n=length(indcol);        % NB Row sums of zero will produce zero row; same for columns.
    for i=1:I
        X(indrow,indcol)=X(indrow,indcol).*kron(ones(m,1),c(indcol)'./sum(X(indrow,indcol)));	% Correction of row sums
        X(indrow,indcol)=X(indrow,indcol).*kron(r(indrow)./sum(X(indrow,indcol)')',ones(1,n));	% Correction of column sums
        if max(abs([sum(X')';sum(X)']-[r;c]))<0.0000001/length(r)
            %disp(['Convergence after ',num2str(i),' iterations'])
            break
        elseif i==I
            Eval(tt,5)=100;
            disp('Max. iterations exceeded')
        end
    end

    Mat(1:size(r,1),1:size(c,1),tt)=X*T;                  % scale back up
    Mat(size(r,1)+1,1:size(c,1),tt)=sum(X*T);             % row sums
    Mat(1:size(r,1),size(c,1)+1,tt)=sum(X*T,2);           % column sums

    % Analysing difference to ME solution
    Eval(tt,1)=tt;
    Eval(tt,2)=norm(Mat(1:size(Assets,1),1:size(Assets,1),tt)-Mat(1:size(Assets,1),1:size(Assets,1),1));                        %Norm
    Eval(tt,3)=nansum(nansum(abs(Mat(1:size(Assets,1),1:size(Assets,1),tt)-Mat(1:size(Assets,1),1:size(Assets,1),1))./Mat(1:size(Assets,1),1:size(Assets,1),1)));       % Sum of relative differences   
    Eval(tt,4)=length(find(Mat(1:size(Assets,1),1:size(Assets,1),tt)==0))-length(Assets);               % total numbers of zeros which are not on diagonal   
end


M_out = Mat(1:end-1,1:end-1,2:end);
