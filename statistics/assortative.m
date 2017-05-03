function [SymPearson Pearson Jackson Newman]= assortative(X)
% [am ad]= assortative(X)
% calculates assortativity, defined as the
% correlation between degrees of nodes that are linked (Jackson book p.66)
% - SymPearson returns straight correlation of symmetrized network
% - Pearson returns straight correlation of original (directed) network
% - Jackson uses deviations from average overall degree 
% - Newman (to implement) uses "remaining degree". Right now it runs Kartik's "assortativity"
% http://en.wikipedia.org/wiki/Assortativity  % for further information.
% Here i stick to simplest definition:
% The assortativity coefficient is the Pearson correlation coefficient of degree between pairs of linked nodes
% 
% Goetz von Peter 1 July 2013 / 22 Jan 2014

% Pearson straight correlation first:
X=spones(X);                % values are not needed for calculating degree:
id=sum(X)'; od=(sum(X')'); td=(id(:)+od(:));
k = td;                     % take total degree (average in & out) as default
[i j]=find(X>0);            % set of linked pairs
am = corr([k(i) k(j)]);     % gives straight correlation
Pearson=am(2,1);

% NB: What this does is a straight correlation using vector-specific means:
% Ki=k(i); Kj=k(j);         % these are the degrees associated with the positive i's and j's
% mi=mean(Ki); mj=mean(Kj);
% numer = (Ki-mi)'*(Kj-mj);
% denom = sqrt((Ki-mi)'*(Ki-mi))*sqrt((Kj-mj)'*(Kj-mj));
% ai = numer/denom;         % gives same result as Pearsson

% Now the Pearson on a symmetrized network:
X=spones(X+X');             % plus places a link if i->j OR j->i (weak definition)
                            % X=spones(max(X,X')) would do the same
id=sum(X)'; od=(sum(X')'); td=(id(:)+od(:));
k = td;                     % take total degree (average in & out) as default
[i j]=find(X>0);            % set of linked pairs
am = corr([k(i) k(j)]);     % gives straight correlation
SymPearson=am(2,1);         % Pearson of the symmetrized adjacency matrix
% NB This gives same results as routine assortativity.m, but is much faster.

% Jackson book (p.66) uses deviations from AVERAGE degree
m=mean(k);              % m=median(k) % possible robust alternative
%m=mean(k(k>0));
[i j]=find(X>0);  
Ki=k(i); Kj=k(j);       % these are the degrees associated with the positive i's and j's*
top = (Ki-m)'*(Kj-m);
bot = sqrt((Ki-m)'*(Ki-m))*sqrt((Kj-m)'*(Kj-m));
Jackson = top/bot;


% Newman (2002) "Assortative mixing" recommends using "remaining degree"
% Of interest to implement Newman (2002)?
% I don't have the code - for now, compare with Kartik's earlier routine: 
if nargout>3
    Newman = assortativity(X); % Returns same result as SymPearson
end


% *Recall indexing:
% http://www.mathworks.ch/company/newsletters/articles/matrix-indexing-in-matlab.html
% positives = X(X>0)      % stacks all positive elements in vector
% n=find(X>0)             % finds where positives are, does same as next line:
% idx = sub2ind(size(B), i, j) % linear indexing, after defining
% [i j]=find(X>0)        % which gives list of indices (not unique) that
% jointly describe the positive elements
