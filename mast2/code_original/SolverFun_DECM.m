
%Procedure for maximizing the likelihood function of our null model, given
%the constraints

function [G,J]=SolverFun_DECM(m,Kout,Kin,Sout,Sin,LengthMarginals)

xOut=m(1:LengthMarginals);
xIn=m(LengthMarginals+1:2*LengthMarginals);
yOut=m(2*LengthMarginals+1:3*LengthMarginals);
yIn=m(3*LengthMarginals+1:4*LengthMarginals);

g=0;
f=0;
for i=1:LengthMarginals
    g=g+Kout(i)*log(xOut(i))+Kin(i)*log(xIn(i))+Sout(i)*log(yOut(i))+Sin(i)*log(yIn(i));
end
for i=1:LengthMarginals
    for j=1:LengthMarginals
        if i~=j
           f=f+log(1-yOut(i)*yIn(j))-log(1-yOut(i)*yIn(j)+xOut(i)*xIn(j)*yOut(i)*yIn(j));
        end
     end
end
G=-(g+f);

jac=zeros(4*LengthMarginals,1);
aux=0;
aux2=0;
aux3=0;
aux4=0;
if nargout>1
for i=1:LengthMarginals
    for j=1:LengthMarginals
        if i~=j
           aux=aux-xIn(j)*yOut(i)*yIn(j)/(1-yOut(i)*yIn(j)+xOut(i)*xIn(j)*yOut(i)*yIn(j));
           aux2=aux2-xOut(j)*yOut(j)*yIn(i)/(1-yOut(j)*yIn(i)+xOut(j)*xIn(i)*yOut(j)*yIn(i));
           aux3=aux3-xOut(i)*xIn(j)*yIn(j)/((1-yOut(i)*yIn(j))*(1-yOut(i)*yIn(j)+xOut(i)*xIn(j)*yOut(i)*yIn(j)));
           aux4=aux4-xOut(j)*xIn(i)*yOut(j)/((1-yOut(j)*yIn(i))*(1-yOut(j)*yIn(i)+xOut(j)*xIn(i)*yOut(j)*yIn(i)));
        end
    end
    jac(i)=Kout(i)/xOut(i)+aux;
    jac(i+LengthMarginals)=Kin(i)/xIn(i)+aux2;
    jac(i+2*LengthMarginals)=Sout(i)/yOut(i)+aux3;
    jac(i+3*LengthMarginals)=Sin(i)/yIn(i)+aux4;
end
end
J=-jac;