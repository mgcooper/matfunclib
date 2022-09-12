function [xpost] = MLEiter(xap,xpre,epsilon,covx,Z,N,M,Fval)
%
% *******************************************
%
% non-linear Maximum Likelihood Estimation
%
% RAS 8/01
%
% *******************************************


% solves iterative formula of Menke (1989), equation 9.10 (p. 151)

% inputs are;
% (1)  xap, prior estimate of the data and model parameters
% (2)  xpre, the previous estimate of x
% (3)  covx, the prior covariance matrix of x
% (4)  epsilon, the iterative convergence parameter
% (5)  Z, a vector with all parameters required for gradient matrix calc
% (6)  N, the number of rows in the gradient matrix (usually number of data points)
% (7)  M, the number of columns in gradient matrix (usually number of parameters)
% (8)  Fval, an index that tells the routine getF about the partial derivative forms
%

flag=1;	% convergence flag = 0 if converged
count=0;

while flag==1       % recursive estimation while MLE has not converged...

% form F matrix, matrix of derivatives

    count=count+1;
    F=zeros(N,M);
    term1=zeros(M,N);
    term2=zeros(N,N);
    term3=zeros(N,1);
    term4=zeros(M,N);
    term5=zeros(M,1);
    xpost=zeros(M,1);
    pert=zeros(M,1);

    F=getgradf(Z,N,M,Fval);	% call function to form gradient matrix

% start forming matrix products required to make next guess

% first calculate function f(xpre)

    f=zeros(N,1);
    f=getf(Z,N,M,Fval);

    term1=covx*F';
    term2=inv(F*term1);
    term3=F*(xpre-xap)-f;
    term4=term1*term2;
    term5=term4*term3;
    xpost=xap+term5;  % new model estimate


    pert=xpost-xpre;  % difference from prior
    test=(abs(pert) >= epsilon);      % epsilon test
    flag=any(test);
    xpre=xpost;
    Z(1:M)=xpre;
    if count >= 100
      pert
    end

end         % end while convergence loop
