
% I am not sure if the author used the return statments correctly and also
% they didn't seem to have the right end statments, see the original
% thesis appendix Kondlo 2010 in measurement error / power law folder

% ALGORITHM 2: MLEs of the log-likelihood function givin in 4.9
% The Matlab codes below minimises the negative log-likelihood function
% with respect to unknown parameters of the convolved PDF. It accepts
% initial estimates (params) and returns the estimated parameter vector
% (paramsEst) obtained by optimization (minimization or maximization)
% procedure.     



function [paramsEst,Funval,exitflag,output] = MAXlikelihood(data,params)
   
% fminsearch = minimize the scalar function loglikfnct, starting at initial (params)
% Funval is the value of the function loglikfnct at the solution paramsEst. 
% exitflag = describe the exit condition of fminsearch: 
%           1 fminsearch converge to a solution paramsEst 
%           0 Maximum number of function evaluations or iterations was reached 
%           -1 Algorithm was terminated by the output function 
% output = structure that contains information about the optimization
   
[paramsEst,Funval,exitflag,output] = fminsearch(@loglikfnct,params,[],data); 
return
   
   
   function [loglikhod] = loglikfnct(params,data) 
   
   % loglikfnct(params,data) function returns the negative log-likelihood value
   z = sort(data); % assigning data to variable z 
   n = length(z); % sample size 

   % initial estimates
   L = params(1); % Lower limit
   U = params(2); % Upper limit 
   a = params(3); % exponent 
   sigma = params(4); % error standard deviation 
   
   % Terminate if the conditions are not met 
   if (a < 0||L < 0||U < L|| sigma < 0) 
      loglikhod = 1.0e+20; 
      return 
   end
      
   % First find the limits of the function only where the integrand is non zero.
   re = 1.e-8; % relative error 
   tol = 1.e-8;
   
   for i = 1:n 
      x = z(i); y = integrand2(x,z(i),a,sigma); 
      
      while y > re 
         x = x - 0.5*sigma; 
         y = integrand2(x,z(i),a,sigma); 
      end
      
      L1 = x; % lower limits
      
      % Note that lower and upper limits must be in the interval [L, U ].
      if (L1 < L) 
         Llim = L; 
      else
         Llim = L1;
      end
      
      x = z(i); 
      y = integrand2(x,z(i),a,sigma); 
      while y > re 
         x = x + 0.5*sigma; 
         y = integrand2(x, z(i), a,sigma); 
      end
      
      U1 = x; % upper limits
      
      if (U1 > U ) 
         Ulim = U; 
      else
         Ulim = U1; 
      end
      
      D(i) = quadl(@integrand2,Llim,Ulim,tol,[],z(i),a,sigma); 
      
   end
   
   % it's possible this is supposed to be quadl function definition
   
   % function body 
   B = n*log(a) - n*log(L^(-a) - U^(-a)); 
   A = -n*log(sigma) - (n/2)*log(2*pi); 
   C = sum(log(D)); 
   loglike = (A + B) + C; 
   loglikhod = -loglike; % negative log-likelihood 
   return
   
   function y = integrand2(x,z,a,sigma) 
      
      % integral part of the log-likelihood function. 
      y = (x.^(-a-1)).*exp((-1/2).*((z - x)./sigma).^2); 
      return
   
      
   end
   
   end
   
end
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
