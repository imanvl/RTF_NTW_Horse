function [Core LossFun]=CorePeriphery(M,Icore)
% Same as PublicUseCore (see that documentation)
% This version for me to experiment. 
% NB We compute all row- and col regularity for both CP and PC, 
% only last few lines (413 onward) determine whether ("strong") or 
% not ("weak") the additional errors are added to penalties
% Therefore, only activate strong or weak version lines 413 onward, 
% not on lines 200!
% Similarly, change error weights on very last line (0*Err...)

% ========= Housekeeping =========
                                    %Check dimensions of the network matrix
N=full(spones(M));                  %Make a 0-1 matrix (ignore link values)

[Msize1 Msize2]=size(N);            %Making sure it is square
if Msize1~=Msize2; error('Enter square matrix'); end

N = diag2zero(N);
logic_net = zeros(Msize1);

%Unconnected nodes will be in the periphery. 
%The next loop cleans out unconnected links, while preserving the
%ordering so that the core, when calculated, will be expanded back to its
%original size.  

for i = 1:size(N);                  %the matrix back to original names
    if sum(N(i,:),1) == 0
        if sum(N(:,i),2) == 0       %if both column and row are identically
            logic_net(i) = 1;       %zero, then logical set
        end
    end
end

N = collapse(logic_net,N);

if nargin<2                             % Set up a random initial partition
   part0 = zeros(size(N,1),1);          % pre-allocate  
    k = round(sqrt(length(part0)));     % # of core banks = root of network dimension
    uno = randsample(length(part0),k);  % picks k places at random in part0 to set to 1
    part0(uno) = 1;                       
   %part0 = (rand(size(N,1),1) < .12)   % alternatively, pick 12% at random
else
    part0 = Icore;
end

% ======== This calls the Main Program =======

    [LossFun Core]=greedyCorePeripheryC(N,part0);
    Core = expand_out(logic_net,Core);

end

function [M] = diag2zero(N)
%clears out diagonal to make it a zero
%Simple routine by Ben Craig March, 2009
M = N;
for obs = 1:size(N,1)
    M(obs,obs) = 0;
end
end

function original = expand_out(logic_net,Smallnet)
%This expands out the network its original size so that the nodes 
% are in their original position.  logic_net
%contains the original sized vector with trues where the row was deleted.
%Ben Craig, October 2009

size_net = size(logic_net,1);
  for i = 1:1:size_net
          if logic_net(i)
              Smallnet = r_and_c_push(Smallnet,i);
          end
  end
  original = Smallnet;

end   
function NMat = r_and_c_push(Mat,n)
%This takes a matrix and inserts a row of zeros at position n.  The
%new matrix is one row longer and one column wider.
%Ben Craig, October 2009

Ms1 = size(Mat,1);

NMat = zeros(Ms1+1,1);
NMat(1:n-1,1) = Mat(1:n-1,1);
NMat(n+1:Ms1+1,1) = Mat(n:Ms1,1);
end  

function  Smallnet = collapse(logic_net,original)
%This collapses a matrix by deleting the row and column whereever logic_net
%has a true
%Ben Craig, October 2009

net = original;
size_net = size(logic_net,1);
if size(original,2) > 1;
  for i = size_net:-1:1
          if logic_net(i)
              net(i,:) = [];               %delete row and column
              net(:,i) = [];
          end
  end
  Smallnet = net;
else
     for i = size_net:-1:1
          if logic_net(i)
              net(i,:) = [];               %delete row and column
          end
     end
end
Smallnet = net;
end
function [Err,part]=greedyCorePeripheryC(Y,part0)
%This has been fixed so that a zero core is allowed. It is not elegant but 
%works in this case.  The cheap fix basically does not allow an empty core
%Ben Craig, August 2009 (based on earlier code by Goetz von Peter.)

%% ================ Housekeeping =================
N=full(spones(Y)); [n j]=size(N);               % Make a 0-1 matrix (ignore values)
if j~=n; error('Enter square matrix'); end

%% ================ Initial model =================
part=part0;


%% ================ Algorithm =================
[original,StoreStruc] = Initialize(N,part) ;
emptycoreflag = false;
t = 1;
iter = 100000;
minerr = n * n;
currentError = minerr;
display_interval = 50;
display_i = 1;
MinErrVec2 = zeros(1,4);
while t<iter    
    
    minobs = 1;
    for obs = 1:n;
       if (sum(part) == 1) && (part(obs) == 1) 
           toterr = minerr + 100;
       else
       [Err,newerr]=IterateStep(N,part,obs,StoreStruc,original); 
       toterr = sum(Err);
       end
       if toterr < minerr;
           minobs = obs;
           minerr = toterr;
           MinErrVec = Err;
       end

    end
    
    if (currentError > minerr)
        [Err,newerr]=IterateStep(N,part,minobs,StoreStruc,original); 
        [StoreStruc,original] = bookkeeper(N,part,minobs,StoreStruc,original,newerr);
    
        part(minobs) = 1 - part(minobs);
        currentError = minerr;
        MinErrVec2 = MinErrVec;
        
    else
%         disp('convergence of greedy algorithm');
%         disp('iterations:'),disp(t);
%         disp('core size:'),disp(prod(size(uint16(find(part==1)))));
%         disp('error'),disp(currentError);
        Err = MinErrVec2;
        return;
    end
    
 if (display_i == display_interval)
%         disp('iterations:'),disp(t);
%         disp('core size:'),disp(prod(size(uint16(find(part==1)))));
%         disp('error'),disp(currentError);
        display_i = 0;
 end
       display_i = display_i + 1; 
       t = t + 1;
       
end   

end

    function [original,StoreStruc]=Initialize(N,part);                % take a network and a core-periphery partition
%% Initialize all of the various vectors so that all subsequent iterations
% can be run as differences from this one.

core=uint16(find(part==1));                 % index set of members
peri=uint16(find(part==0));

CC=N(core,core); CP=N(core,peri);           % Break network into core & periphery...
PC=N(peri,core); PP=N(peri,peri);           % ... by grabbing rows&cols of index set
c=length(core); p=length(peri);             % count members
totlength = c + p;

original.CC=c*(c-1)-nnz(CC);                      
original.PP=nnz(PP);                             

% From core to periphery (CP block)         % regular block requires both:
original.RRCP=sum(1-any(CP,2));             % row-regular: Note that this does not assign 
                                            %penalty yet
original.CRCP=sum(1-any(CP,1));             % For FULL regulartiy: Punish zero cols (peri not connected)
                                            %Same not as above
% From periphery to core (PC block)         % regular block again requires both:
original.CRPC=sum(1-any(PC,1));             % col-regular 
original.RRPC=sum(1-any(PC,2));             % For FULL regularity add row-regular requirement

%% INITIALIZE THE SUMS ON THE INITIAL NETWORK ===============
StoreStruc.SCPI = zeros(totlength,1);
StoreStruc.SCPJ = zeros(totlength,1);
StoreStruc.SPCI = zeros(totlength,1);
StoreStruc.SPCJ = zeros(totlength,1);

StoreStruc.SCPI(peri) = sum(CP,1)';
StoreStruc.SCPJ(core) = sum(CP,2);
StoreStruc.SPCI(core) = sum(PC,1)';
StoreStruc.SPCJ(peri) = sum(PC,2);

end 

function [Err,newerr]=IterateStep(N,part,k,StoreStruc,original) 
%% The main problem in going from n2 to n order caluculation is the
% bookkeeping.  The sum vectors have to be redone after each iteration and
% the spaces have to be tracked.  This is done essentially by
% redefining the sum vectors each time without recalculation.  This avoids
% the n2 order resumming, and avoids the keeping track of all the i and
% j's that working with permuation vectors would have entailed.  
% Instead  there is an order n allocation as the vectors are redefined.  
% So everything in this section is of order n

core=uint16(find(part==1));                 % index set of members
peri=uint16(find(part==0));
c=length(core); p=length(peri); 
if (c == 0);
    n2 = (p + c) * (p + c);
    Err=[n2 n2 n2 n2]; 
    newerr.CC = n2 ;
    newerr.PP = n2;
    newerr.RRCP = n2;
    newerr.CRCP = n2 ;
    newerr.RRPC = n2;
    newerr.CRPC = n2;
    
    return;
end

CCKJ=N(k,core);                             %1xc
CPI=N(k,peri);                              %1xp
                                            % Break vectors into core and periphery
PCI=N(k,core);                              %1xc
PPKJ=N(k,peri);                             %1xp
CCIK=N(core,k);                             %cx1
CPJ=N(core,k);                              %cx1 
PCJ=N(peri,k);                              %px1
PPIK=N(peri,k);                             %px1          
         

SCCJ = sum(CCKJ);                           %1x1
SCCI = sum(CCIK);                           %1x1
SCPI = StoreStruc.SCPI(peri);               %px1
SCPIL1 = (SCPI == 1);                       %px1
SCPIL0 = (SCPI == 0);                       %px1
SCPJ = StoreStruc.SCPJ(core);               %cx1
SCPJL1 = (SCPJ == 1);                       %cx1
SCPJL0 = (SCPJ == 0);                       %cx1
SPCI = StoreStruc.SPCI(core);               %cx1
SPCIL1 = (SPCI == 1);                       %cx1
SPCIL0 = (SPCI == 0);                       %cx1
SPCJ = StoreStruc.SPCJ(peri);               %px1
SPCJL1 = (SPCJ == 1);                       %px1
SPCJL0 = (SPCJ == 0);                       %px1
SPPJ = sum(PPKJ);                           %1x1
SPPI = sum(PPIK);                           %1x1


%% STEP 1: SWITCH k's FROM CORE TO PERI ===============

if part(k) == 1;

kcoreplace=uint16(find(core==k));           % index set of members
%First k goes from C to P (dcp)
%In CP lose one Row (l)
%Row Regular (RR)
dcpCPlRR = SCPJL0(kcoreplace);
%Column Regular
dcpCPlCR = -(CPI * SCPIL1);
%In CP gain one Column (g)
dcpCPgRR = -(SCPJL0' * CCIK);
dcpCPgCR = (SCCI == 0);

%In PC lose one Column gain one Row

dcpPClRR = -(SPCJL1' * PCJ);
dcpPClCR = (SPCIL0(kcoreplace));
dcpPCgRR = (SCCJ == 0);
dcpPCgCR = -(CCKJ * SPCIL0);

%Now the loss of column and row in CC
dcpCCl = (2*(c-1)) - (SCCJ + SCCI);
%Gain the column and row of the new PP
dcpPPg = SPCI(kcoreplace) + SCPJ(kcoreplace);

end;

%% STEP 2: SWITCH k's FROM PERI TO CORE ===============

if part(k) == 0;
kperiplace=uint16(find(peri==k));  
%Next we look at the errors for the k's that go from P to C (dpc)
%In CP lose one Column (l)
%Row Regular (RR)
dpcCPlRR = -(SCPJL1' * CPJ);
%Column Regular
dpcCPlCR = SCPIL0(kperiplace);
%In CP gain one row (g)
dpcCPgRR =  (SPPJ == 0);
dpcCPgCR = -(PPKJ * SCPIL0);

%In PC lose one row gain one column

dpcPClRR = SPCJL0(kperiplace);
dpcPClCR = -(PCI * SPCIL1);
dpcPCgRR = -(SPCJL0' * PPIK);
dpcPCgCR = (SPPI == 0)';

%Lose row and column in PP gain row and column in CC
dpcCCg = (2*c) - (SPCJ(kperiplace) + SCPI(kperiplace));
dpcPPl = (SPPJ + SPPI);
end;

%% STEP 3: AGGREGATE ERRORS ===============
%Now we aggegate everthing up and add the differences to the original
%losses to come up with the total losses.  Note that I still maintain the
%distinction between blocks and between CR and RR so that the proper
%penalties can be assigned.

if part(k) == 1;
newerr.CC = original.CC - dcpCCl ;
newerr.PP = original.PP + dcpPPg;
newerr.RRCP = original.RRCP - (dcpCPlRR - dcpCPgRR);
newerr.CRCP = original.CRCP - (dcpCPlCR - dcpCPgCR) ;
newerr.RRPC = original.RRPC - (dcpPClRR - dcpPCgRR);
newerr.CRPC = original.CRPC - (dcpPClCR - dcpPCgCR);
end;

if part(k) == 0;
newerr.CC = original.CC + dpcCCg ;
newerr.PP = original.PP - dpcPPl ;
newerr.RRCP = original.RRCP - (dpcCPlRR - dpcCPgRR);
newerr.CRCP = original.CRCP - (dpcCPlCR - dpcCPgCR);
newerr.RRPC = original.RRPC - (dpcPClRR - dpcPCgRR);
newerr.CRPC = original.CRPC - (dpcPClCR - dpcPCgCR);   
end;

partk = part(k);
Err = assignPenalties(partk,newerr,p,c);


end
% -----------------------------
% Now the difficult part.  If k is accepted, more bookkeeping us needed, 
% and it has to remain under order n for efficiency.
function [StoreStruc,original] = bookkeeper(N,part,k,StoreStruc,original,newerr)

core=uint16(find(part==1));                 % index set of members
peri=uint16(find(part==0));

if part(k) == 1;

StoreStruc.SPCI(k) = 0 ;
StoreStruc.SPCI(core) = StoreStruc.SPCI(core) + (N(k,core))';
StoreStruc.SPCJ(k) = sum(N(k,core)) ;
StoreStruc.SPCJ(peri) = StoreStruc.SPCJ(peri) - N(peri,k);


StoreStruc.SCPJ(k) = 0 ;
StoreStruc.SCPJ(core) = StoreStruc.SCPJ(core) + N(core,k);
StoreStruc.SCPI(k) = sum(N(core,k)) ;
StoreStruc.SCPI(peri) = StoreStruc.SCPI(peri) - (N(k,peri))';
end;

if part(k) == 0;
StoreStruc.SPCI(k) = sum(N(peri,k)) ;
StoreStruc.SPCI(core) = StoreStruc.SPCI(core) - (N(k,core))';
StoreStruc.SPCJ(k) = 0 ;
StoreStruc.SPCJ(peri) = StoreStruc.SPCJ(peri) + N(peri,k);


StoreStruc.SCPJ(k) = sum(N(k,peri)) ;
StoreStruc.SCPJ(core) = StoreStruc.SCPJ(core) - N(core,k);
StoreStruc.SCPI(k) = 0 ;
StoreStruc.SCPI(peri) = StoreStruc.SCPI(peri) + (N(k,peri))';
end;   

original.CC = newerr.CC ;
original.PP = newerr.PP ;
original.RRCP = newerr.RRCP ;
original.CRCP = newerr.CRCP ;
original.RRPC = newerr.RRPC ;
original.CRPC = newerr.CRPC ;

end

function [Err] = assignPenalties(partk,newerr,p,c)
%% STEP 4: ASSIGN PENALTIES AND DEFINE OUTPUT ===============
%Only now can penalties be assigned (because of the change of size in PC and
%CP in the final matrices once a node has changed, had to wait until here to multiply.)

if partk == 1;
    

 
% Strong Version
% dcpCP = [(p+1);(c-1)];
% dcpPC = [(c-1);(p+1)];
% errCP = [newerr.RRCP newerr.CRCP] * dcpCP ;
% errPC = [newerr.RRPC newerr.CRPC] * dcpPC ;
% Weak Version
errCP = newerr.RRCP * (p+1) ;
errPC = newerr.CRPC * (p+1) ;
end;

if partk == 0;
% %Strong Version
% dpcCP = [(p-1);(c+1)];  %that is, when a node moves from P to C, CP gains a col
%                         %and loses a row, so that the penalty for row
%                         %regularity or column regularity violations change.
%                         %The convention here is the same as above: dpc
%                         %means the node changes from p to c, and CP means
%                         %that we are looking at penalties for RR and CR
%                         %violations in the CP block.
% dpcPC = [(c+1);(p-1)]; 

% errCP = [newerr.RRCP newerr.CRCP] * dpcCP ;
% errPC = [newerr.RRPC newerr.CRPC] * dpcPC ;
%Weak Version
errCP = newerr.RRCP * (p-1) ;
errPC = newerr.CRPC * (p-1) ;
end;
Err=[newerr.CC errCP errPC newerr.PP];          % Equally weighted error matrix and score
%Err=[newerr.CC 0*errCP 0*errPC newerr.PP];     % TO IGNORE OFF-DIAG


end