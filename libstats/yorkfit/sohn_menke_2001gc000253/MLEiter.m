function [xpost] = MLEiter(xap,xpre,epsilon,covx)
%
% *******************************************
%
% non-linear Maximum Likelihood Estimation of a straight line
% to double error data
%
% RAS 7/00
%
% *******************************************


% solves iterative formula of Menke (1989), equation 9.10 (p. 151)

% inputs are xap, the prior estimate of the combined data and model
% vector x; xpre, the previous estimate of x; covx, the prior
% covariance matrix of x; and epsilon, the
% iterative convergence parameter
%
% first N values of xpre are the x-values of the data pairs
% second N values of xpre are the y-values of the data pairs
% 2N+1 value of xpre is the model slope
% 2N+2 value of xpre is the model intercept



M=length(xpre);	% number of parameters
N=(M-2)/2;	% number of observations

flag=1;	% convergence flag = 0 if converged

while flag==1       % recursive estimation while MLE has not converged...

% form F matrix, matrix of derivatives

    F=zeros(N,M);
    term1=zeros(M,N);
    term2=zeros(N,N);
    term3=zeros(N,1);
    term4=zeros(M,N);
    term5=zeros(M,1);
    xpost=zeros(M,1);
    pert=zeros(M,1);
    df1=ones(N,1)*xpre(2*N+1);
    df2=-ones(N,1);

    F(:,1:N)=diag(df1);
    F(:,N+1:2*N)=diag(df2);
    F(:,2*N+2)=ones(N,1);
    F(1:N,2*N+1)=xpre(1:N);

% start forming matrix products required to make next guess

% first calculate function f(xpre)

    f=zeros(N,1);
    for j=1:N
       f(j)=xpre(2*N+1)*xpre(j)+xpre(2*N+2)-xpre(N+j);
    end

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

end         % end while convergence loop
