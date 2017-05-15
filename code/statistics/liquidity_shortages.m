function sls = liquidity_shortages(dd, B, l)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% liquidityShortfall_fun computes the change in liquid assets according to
% the fixed-point solution of Lee (2013)

% INPUT:      
%       B         - matrix of liqbility obligations (#banks x #banks)
%       l         - vector of liquid assets (#banks x 1)
%       dd        - liquididity run-off shock (#banks x 1)
%
% OUTPUT:      
%       sls       - liquidity shortfall summed over all banks
%
% REMARK:
%       Lee, S.H. (2013) Systemic liquidity shortage and interbank network
%       structure, Journal of Financial Stability, vol. 9, pages 1-12
%
% ------------------------------------------------------------------------------
% Created by: Seung Hwan Lee (Bank of Korea)
% This version: 26/11/2014
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%% LIQUIDITY WITHDRAWALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=length(dd); % d=deposits
%dd=wr.*d; % wr=withdrawal rate, dd=withdrawal amount
%%%%%%%%%%%%%%%%%%%%%%%%% Relative Liquid Asset Ratio %%%%%%%%%%%%%%%%%%%%%
%LM=[B;q]; % B: interbank exposure matrix, q: liquid non-bank assets
          % LM: Liquid Asset Matrix
%l=ones(1,N+1)*LM; % l:Total Liquid Assets
PI=B/(diag(l)); % PI_: Relative Liquid Asset Ratio
%PI=PI_(1:end-1,:); % PI: Relative Interbank Liquid Asset Ratio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BM=[[B;q;z] [d;0;0]]; % z:illiquid assets
%%%%%%%%%%%%%%%%%%%%%%%%% SYSTEMIC LIQUIDITY SHORTAGE %%%%%%%%%%%%%%%%%%%%%
I=eye(N);
dl= (I-PI)\dd; % initial value
for i=1:N
v=l'-(dd+PI*dl); % v=total liquid assets-withdrawal(direct(dd)&indirect(PI*dl))
L=diag(v<0); % shortage indicator(liquiidty shortage=1, otherwise=0)
dl=(I-(I-L)*PI*(I-L))\((I-L)*dd+((I-L)*PI*L+L)*l'); % dl: changes in liquid assets
end

ls=L*(PI*dl+dd-l'); % liquidity shortages
sls=sum(ls); % sls: systemic liquidity shortages
ln=dl+ls; % liquidity needs
