
% In and out degrees
[~, indeg, outdeg] = degrees(spones(M_orig));
quantilesIn = quantile(indeg,[.25 .50 .75]);
quantilesOut = quantile(indeg,[.25 .50 .75]);

outputMatrices.orig.degree.in.min = min(indeg);
outputMatrices.orig.degree.in.max = max(indeg);
outputMatrices.orig.degree.in.mean = mean(indeg);
outputMatrices.orig.degree.in.p25 = quantilesIn(1);
outputMatrices.orig.degree.in.p50 = quantilesIn(2);
outputMatrices.orig.degree.in.p75 = quantilesIn(3);

outputMatrices.orig.degree.out.min = min(outdeg);
outputMatrices.orig.degree.out.max = max(outdeg);
outputMatrices.orig.degree.out.mean = mean(outdeg);
outputMatrices.orig.degree.out.p25 = quantilesOut(1);
outputMatrices.orig.degree.out.p50 = quantilesOut(2);
outputMatrices.orig.degree.out.p75 = quantilesOut(3);

% Closeness centrality
close = closeness(M_orig);
quantilesClose = quantile(close,[.25 .50 .75]);

outputMatrices.orig.closeness.min = min(close);
outputMatrices.orig.closeness.max = max(close);
outputMatrices.orig.closeness.mean = mean(close);
outputMatrices.orig.closeness.p25 = quantilesClose(1);
outputMatrices.orig.closeness.p50 = quantilesClose(2);
outputMatrices.orig.closeness.p75 = quantilesClose(3);

% Betweenness centrality
betweenness = betweenness_centrality_2(1*(M_orig>0));
quantilesBetweenness = quantile(betweenness,[.25 .50 .75]);

outputMatrices.orig.betweenness.min = min(betweenness);
outputMatrices.orig.betweenness.max = max(betweenness);
outputMatrices.orig.betweenness.mean = mean(betweenness);
outputMatrices.orig.betweenness.p25 = quantilesBetweenness(1);
outputMatrices.orig.betweenness.p50 = quantilesBetweenness(2);
outputMatrices.orig.betweenness.p75 = quantilesBetweenness(3);

% Eigenvalue centrality
eigenvalues = eigencentrality(1*(M_orig > 0));
quantilesEigen = quantile(eigenvalues,[.25 .50 .75]);

outputMatrices.orig.eigen.min = min(eigenvalues);
outputMatrices.orig.eigen.max = max(eigenvalues);
outputMatrices.orig.eigen.mean = mean(eigenvalues);
outputMatrices.orig.eigen.p25 = quantilesEigen(1);
outputMatrices.orig.eigen.p50 = quantilesEigen(2);
outputMatrices.orig.eigen.p75 = quantilesEigen(3);

clear('indeg','outdeg','quantilesIn','quantilesOut','close',...
    'quantilesClose','betweenness','quantilesBetweenness','eigenvalues',...
    'quantilesEigen');