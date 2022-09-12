
% Algorithm 1: Simulations
% 1. For a given model Y = X + , where the variable X follows a Pareto PDF
% given in (4.1) and  ∼ N (0, σ2). 
% 2. Let z = FX(x), then x = (L^−a − z(L^−a − U^−a))^(−1/a), refer to 4.2.
% Given the parameter vector values [L, U, a], desired sample size n and 
% z ∼ U (0, 1); x in (2) above returns the un-contaminated simulated data. 
% 3. Adding the Gaussian error with mean zero and variance σ2 to x. The
% errorcontaminated data Y = x +  is produced. 

function [Y] = SimuPareto(n,params)

% inputs: desired sample size n and the parameter vector values [L, U, asigma] 
L     = params(1); % lower limit 
U     = params(2); % upper limit 
a     = params(3); % exponent or power indices 
sigma = params(4); % error standard deviation

%**************************************************************************
z = rand(n,1); % vector of uniformly distributed pseudo-random numbers. 
x = ((L.^(-a) - z.*(L.^(-a) - U.^(-a))).^(-1./a)); 
e = sigma*randn(n,1); 
Y = x + e;
%**************************************************************************
% The histograms 
subplot(2,1,1),hist(x)
title('UN-CONTAMINATED DATA')
subplot(2,1,2),hist(Y); 
title('ERROR-CONTAMINATED DATA') 
return

