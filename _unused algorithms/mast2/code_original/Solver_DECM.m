
%Procedure for solving the likelihood equations of our null model, given
%the constraints

function [G,J]=Solver_DECM(m,ExpKout,ExpKin,Sout,Sin,LengthMarginals)

xOut=m(1:LengthMarginals);
xIn=m(LengthMarginals+1:2*LengthMarginals);
yOut=m(2*LengthMarginals+1:3*LengthMarginals);
yIn=m(3*LengthMarginals+1:4*LengthMarginals);

g=zeros(LengthMarginals,1);
f=zeros(LengthMarginals,1);
h=zeros(LengthMarginals,1);
k=zeros(LengthMarginals,1);
         for i=1:LengthMarginals
            for j=1:LengthMarginals
                if i~=j
                   g(i)=g(i)+(xOut(i)*xIn(j)*yOut(i)*yIn(j))/(1-yOut(i)*yIn(j)+xOut(i)*xIn(j)*yOut(i)*yIn(j));
                   f(i)=f(i)+(xOut(j)*xIn(i)*yOut(j)*yIn(i))/(1-yOut(j)*yIn(i)+xOut(j)*xIn(i)*yOut(j)*yIn(i));
                   h(i)=h(i)+(xOut(i)*xIn(j)*yOut(i)*yIn(j))/((1-yOut(i)*yIn(j)+xOut(i)*xIn(j)*yOut(i)*yIn(j))*(1-yOut(i)*yIn(j)));
                   k(i)=k(i)+(xOut(j)*xIn(i)*yOut(j)*yIn(i))/((1-yOut(j)*yIn(i)+xOut(j)*xIn(i)*yOut(j)*yIn(i))*(1-yOut(j)*yIn(i)));
                end
            end
         end
Observed=[ExpKout;ExpKin;Sout;Sin];         
Expected=[g;f;h;k];
G=Observed-Expected;

jac=zeros(4*LengthMarginals,4*LengthMarginals);
         for i=1:LengthMarginals
             for j=1:LengthMarginals
                 if i~=j
                    jac(i,i)=jac(i,i)+(xIn(j)*yOut(i)*yIn(j)*(1-yOut(i)*yIn(j)))/(1-yOut(i)*yIn(j)+xOut(i)*xIn(j)*yOut(i)*yIn(j))^2;
                 end
             end
         end
         for i=1:LengthMarginals
             for j=(LengthMarginals+1):(2*LengthMarginals)
                 if i~=(j-LengthMarginals)
                    jac(i,j)=(xOut(i)*yOut(i)*yIn(j-LengthMarginals)*(1-yOut(i)*yIn(j-LengthMarginals)))/(1-yOut(i)*yIn(j-LengthMarginals)+xOut(i)*xIn(j-LengthMarginals)*yOut(i)*yIn(j-LengthMarginals))^2;
                 end
             end
         end
         for i=1:LengthMarginals
             for j=(2*LengthMarginals+1):(3*LengthMarginals)
                 if i~=(j-2*LengthMarginals)
                    jac(i,i+2*LengthMarginals)=jac(i,i+2*LengthMarginals)+(xOut(i)*xIn(j-2*LengthMarginals)*yIn(j-2*LengthMarginals))/(1-yOut(i)*yIn(j-2*LengthMarginals)+xOut(i)*xIn(j-2*LengthMarginals)*yOut(i)*yIn(j-2*LengthMarginals))^2;
                 end
             end
         end
         for i=1:LengthMarginals
             for j=(3*LengthMarginals+1):(4*LengthMarginals)
                 if i~=(j-3*LengthMarginals)
                    jac(i,j)=(xOut(i)*xIn(j-3*LengthMarginals)*yOut(i))/(1-yOut(i)*yIn(j-3*LengthMarginals)+xOut(i)*xIn(j-3*LengthMarginals)*yOut(i)*yIn(j-3*LengthMarginals))^2;
                 end
             end
         end
%%%%%%%%%
         for i=(LengthMarginals+1):(2*LengthMarginals)
             for j=1:LengthMarginals
                 if (i-LengthMarginals)~=j
                    jac(i,j)=(xIn(i-LengthMarginals)*yOut(j)*yIn(i-LengthMarginals)*(1-yOut(j)*yIn(i-LengthMarginals)))/(1-yOut(j)*yIn(i-LengthMarginals)+xOut(j)*xIn(i-LengthMarginals)*yOut(j)*yIn(i-LengthMarginals))^2;
                 end
             end
         end
         for i=(LengthMarginals+1):(2*LengthMarginals)
             for j=(LengthMarginals+1):(2*LengthMarginals)
                 if i~=j
                    jac(i,i)=jac(i,i)+(xOut(j-LengthMarginals)*yOut(j-LengthMarginals)*yIn(i-LengthMarginals)*(1-yOut(j-LengthMarginals)*yIn(i-LengthMarginals)))/(1-yOut(j-LengthMarginals)*yIn(i-LengthMarginals)+xOut(j-LengthMarginals)*xIn(i-LengthMarginals)*yOut(j-LengthMarginals)*yIn(i-LengthMarginals))^2;
                 end
             end
         end
         for i=(LengthMarginals+1):(2*LengthMarginals)
             for j=(2*LengthMarginals+1):(3*LengthMarginals)
                 if (i-LengthMarginals)~=(j-2*LengthMarginals)
                    jac(i,j)=(xOut(j-2*LengthMarginals)*xIn(i-LengthMarginals)*yIn(i-LengthMarginals))/(1-yOut(j-2*LengthMarginals)*yIn(i-LengthMarginals)+xOut(j-2*LengthMarginals)*xIn(i-LengthMarginals)*yOut(j-2*LengthMarginals)*yIn(i-LengthMarginals))^2;
                 end
             end
         end
         for i=(LengthMarginals+1):(2*LengthMarginals)
             for j=(3*LengthMarginals+1):(4*LengthMarginals)
                 if (i-LengthMarginals)~=(j-3*LengthMarginals)
                    jac(i,i+2*LengthMarginals)=jac(i,i+2*LengthMarginals)+(xOut(j-3*LengthMarginals)*xIn(i-LengthMarginals)*yOut(j-3*LengthMarginals))/(1-yOut(j-3*LengthMarginals)*yIn(i-LengthMarginals)+xOut(j-3*LengthMarginals)*xIn(i-LengthMarginals)*yOut(j-3*LengthMarginals)*yIn(i-LengthMarginals))^2;
                 end
             end
         end
%%%%%%%%%         
         for i=(2*LengthMarginals+1):(3*LengthMarginals)
             for j=1:LengthMarginals
                 if (i-2*LengthMarginals)~=j
                    %jac(i,i-2*LengthMarginals)=jac(i,i-2*LengthMarginals)+(xIn(j)*yOut(i-2*LengthMarginals)*yIn(j)*(1-yOut(i-2*LengthMarginals)*yIn(j))^2)/((1-yOut(i-2*LengthMarginals)*yIn(j)+xOut(i-2*LengthMarginals)*xIn(j)*yOut(i-2*LengthMarginals)*yIn(j))*(1-yOut(i-2*LengthMarginals)*yIn(j)))^2;
                    jac(i,i-2*LengthMarginals)=jac(i,i-2*LengthMarginals)+(xIn(j)*yOut(i-2*LengthMarginals)*yIn(j))/(1-yOut(i-2*LengthMarginals)*yIn(j)+xOut(i-2*LengthMarginals)*xIn(j)*yOut(i-2*LengthMarginals)*yIn(j))^2;
                 end
             end
         end
          for i=(2*LengthMarginals+1):(3*LengthMarginals)
             for j=(LengthMarginals+1):(2*LengthMarginals)
                 if (i-2*LengthMarginals)~=(j-LengthMarginals)
                    %jac(i,j)=(xOut(i-2*LengthMarginals)*yOut(i-2*LengthMarginals)*yIn(j-LengthMarginals)*(1-yOut(i-2*LengthMarginals)*yIn(j-LengthMarginals))^2)/((1-yOut(i-2*LengthMarginals)*yIn(j-LengthMarginals)+xOut(i-2*LengthMarginals)*xIn(j-LengthMarginals)*yOut(i-2*LengthMarginals)*yIn(j-LengthMarginals))*(1-yOut(i-2*LengthMarginals)*yIn(j-LengthMarginals)))^2;
                    jac(i,j)=(xOut(i-2*LengthMarginals)*yOut(i-2*LengthMarginals)*yIn(j-LengthMarginals))/(1-yOut(i-2*LengthMarginals)*yIn(j-LengthMarginals)+xOut(i-2*LengthMarginals)*xIn(j-LengthMarginals)*yOut(i-2*LengthMarginals)*yIn(j-LengthMarginals))^2;
                 end
             end
          end
          for i=(2*LengthMarginals+1):(3*LengthMarginals)
             for j=(2*LengthMarginals+1):(3*LengthMarginals)
                 if i~=j
                    jac(i,i)=jac(i,i)+(xOut(i-2*LengthMarginals)*xIn(j-2*LengthMarginals)*yIn(j-2*LengthMarginals)*(1-yOut(i-2*LengthMarginals)^2*yIn(j-2*LengthMarginals)^2*(1-xOut(i-2*LengthMarginals)*xIn(j-2*LengthMarginals))))/((1-yOut(i-2*LengthMarginals)*yIn(j-2*LengthMarginals)+xOut(i-2*LengthMarginals)*xIn(j-2*LengthMarginals)*yOut(i-2*LengthMarginals)*yIn(j-2*LengthMarginals))*(1-yOut(i-2*LengthMarginals)*yIn(j-2*LengthMarginals)))^2;
                 end
             end
          end
          for i=(2*LengthMarginals+1):(3*LengthMarginals)
             for j=(3*LengthMarginals+1):(4*LengthMarginals)
                 if (i-2*LengthMarginals)~=(j-3*LengthMarginals)
                    jac(i,j)=(xOut(i-2*LengthMarginals)*xIn(j-3*LengthMarginals)*yOut(i-2*LengthMarginals)*(1-yOut(i-2*LengthMarginals)^2*yIn(j-3*LengthMarginals)^2*(1-xOut(i-2*LengthMarginals)*xIn(j-3*LengthMarginals))))/((1-yOut(i-2*LengthMarginals)*yIn(j-3*LengthMarginals)+xOut(i-2*LengthMarginals)*xIn(j-3*LengthMarginals)*yOut(i-2*LengthMarginals)*yIn(j-3*LengthMarginals))*(1-yOut(i-2*LengthMarginals)*yIn(j-3*LengthMarginals)))^2;
                 end
             end
          end
%%%%%%%%%         
         for i=(3*LengthMarginals+1):(4*LengthMarginals)
             for j=1:LengthMarginals
                 if (i-3*LengthMarginals)~=j
                    %jac(i,j)=(xIn(i-3*LengthMarginals)*yOut(j)*yIn(i-3*LengthMarginals)*(1-yOut(j)*yIn(i-3*LengthMarginals))^2)/((1-yOut(j)*yIn(i-3*LengthMarginals)+xOut(j)*xIn(i-3*LengthMarginals)*yOut(j)*yIn(i-3*LengthMarginals))*(1-yOut(j)*yIn(i-3*LengthMarginals)))^2;
                    jac(i,j)=(xIn(i-3*LengthMarginals)*yOut(j)*yIn(i-3*LengthMarginals))/(1-yOut(j)*yIn(i-3*LengthMarginals)+xOut(j)*xIn(i-3*LengthMarginals)*yOut(j)*yIn(i-3*LengthMarginals))^2;
                 end
             end
         end
         for i=(3*LengthMarginals+1):(4*LengthMarginals)
             for j=(LengthMarginals+1):(2*LengthMarginals)
                 if (i-3*LengthMarginals)~=(j-LengthMarginals)
                    %jac(i,i-2*LengthMarginals)=jac(i,i-2*LengthMarginals)+(xOut(j-LengthMarginals)*yOut(j-LengthMarginals)*yIn(i-3*LengthMarginals)*(1-yOut(j-LengthMarginals)*yIn(i-3*LengthMarginals))^2)/((1-yOut(j-LengthMarginals)*yIn(i-3*LengthMarginals)+xOut(j-LengthMarginals)*xIn(i-3*LengthMarginals)*yOut(j-LengthMarginals)*yIn(i-3*LengthMarginals))*(1-yOut(j-LengthMarginals)*yIn(i-3*LengthMarginals)))^2;
                    jac(i,i-2*LengthMarginals)=jac(i,i-2*LengthMarginals)+(xOut(j-LengthMarginals)*yOut(j-LengthMarginals)*yIn(i-3*LengthMarginals))/(1-yOut(j-LengthMarginals)*yIn(i-3*LengthMarginals)+xOut(j-LengthMarginals)*xIn(i-3*LengthMarginals)*yOut(j-LengthMarginals)*yIn(i-3*LengthMarginals))^2;
                 end
             end
         end
         for i=(3*LengthMarginals+1):(4*LengthMarginals)
             for j=(2*LengthMarginals+1):(3*LengthMarginals)
                 if (i-3*LengthMarginals)~=(j-2*LengthMarginals)
                    jac(i,j)=(xOut(j-2*LengthMarginals)*xIn(i-3*LengthMarginals)*yIn(i-3*LengthMarginals)*(1-yOut(j-2*LengthMarginals)^2*yIn(i-3*LengthMarginals)^2*(1-xOut(j-2*LengthMarginals)*xIn(i-3*LengthMarginals))))/((1-yOut(j-2*LengthMarginals)*yIn(i-3*LengthMarginals)+xOut(j-2*LengthMarginals)*xIn(i-3*LengthMarginals)*yOut(j-2*LengthMarginals)*yIn(i-3*LengthMarginals))*(1-yOut(j-2*LengthMarginals)*yIn(i-3*LengthMarginals)))^2;
                 end
             end
         end
         for i=(3*LengthMarginals+1):(4*LengthMarginals)
             for j=(3*LengthMarginals+1):(4*LengthMarginals)
                 if i~=j
                    jac(i,i)=jac(i,i)+(xOut(j-3*LengthMarginals)*xIn(i-3*LengthMarginals)*yOut(j-3*LengthMarginals)*(1-yOut(j-3*LengthMarginals)^2*yIn(i-3*LengthMarginals)^2*(1-xOut(j-3*LengthMarginals)*xIn(i-3*LengthMarginals))))/((1-yOut(j-3*LengthMarginals)*yIn(i-3*LengthMarginals)+xOut(j-3*LengthMarginals)*xIn(i-3*LengthMarginals)*yOut(j-3*LengthMarginals)*yIn(i-3*LengthMarginals))*(1-yOut(j-3*LengthMarginals)*yIn(i-3*LengthMarginals)))^2;
                 end
             end
         end
J=-jac;