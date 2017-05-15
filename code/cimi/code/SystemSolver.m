
%Procedure for computing the likelihood function of our null model, given
%the constraints

function [G,J]=SystemSolver(z,SOut,SIn,LengthMarginals,Link)

g=0;
jac=0;
        for i=1:LengthMarginals
            for j=1:i-1
                g=g+(z*SOut(i)*SIn(j))/(1+z*SOut(i)*SIn(j))+(z*SOut(j)*SIn(i))/(1+z*SOut(j)*SIn(i));
                jac=jac+(SOut(i)*SIn(j))/(1+z*SOut(i)*SIn(j))^2+(SOut(j)*SIn(i))/(1+z*SOut(j)*SIn(i))^2;
            end
        end
        
G=g-Link;
J=jac;