
function sig = errorprop(FofX,X,sigX,varargin)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   p = MipInputParser;
   p.FunctionName = 'errorprop';
   p.addRequired('FofX',@(x)isa(x,'function_handle'));
   p.addRequired('X',@(x)isnumeric(x));
   p.addRequired('sigX',@(x)isnumeric(x));
   p.addParameter('correlated',false,@(x)islogical(x));
   p.parseMagically('caller');
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%    this doesn't work b/c if you pass it a function handle and a set of
%    vectors that the function accepts it then outputs a vector but the
%    jacobian is computed as though the output was a scalar so i need to
%    compute the jacobian differently then it will work

   % F is an in-line scalar valued function that takes vector X as input
   % X is a vector of scalars or array of column vectors 
   % sigX is the uncertainty of each variable in vars
   
   % NOTE: the compact notation: sig = sqrt(J*V*J'), where V=cov(vars) will
   % not give consistent results because it assumes the uncertainty in each
   % input variable is the standard deviation of the supplied values, but
   % it is possible that the uncertainty was estimated by some other means,
   % e.g., a monte carlo or bootstrap analysis, and maybe there isn't a
   % consistent sample size of each variable in vars for these methods, but
   % there is a consistent sample size of each variable in vars using some
   % other method that is separate from the uncertainty estimate, and those
   % consistent sample sizes are used to get the correlation matrix, and
   % then the correlation matrix is multiplied by the uncertainties
   
   % if vars contains the same vectors that are used to estimate the stdvs,
   % then sig = sqrt(J*V*J') should work
   
   % use u for compact notation
   u     = sigX;                 % uncertainties
   J     = FofX(X)./X;           % Jacobian
   %J    = jacobian(F(X));
   
   if correlated == false
      sig   = sqrt(sum((J.*u).^2));
      return;
   end

   % total error with correlated variables
   C     = corr(X);              % correlation matrix
   V     = u.*u'.*C;             % covariance matrix
   sig   = sqrt(J*V*J');

% % this does the same thing that u.*u'.*C does   
%    % multiply the off-diagonals by the uncertainties
%    N     = numel(J);
%    V     = corr(vars);  % correlation matrix
%    for n = 1:N
%       V(n,:)=V(n,:).*u(n);
%       V(:,n)=V(:,n).*u(n);
%    end
%    sig   = sqrt(J*V*J');

% the covariance matrix is:
% [ sig1*sig1  sig1*sig2   sig1*sig3   ] * [ rho11 rho12 rho13 ]
% [ sig2*sig1  sig2*sig2   sig2*sig3   ]   [ rho21 rho22 rho23 ]
% [ sig3*sig1  sig3*sig2   sig3*sig3   ]   [ rho31 rho32 rho33 ]

% we get the left side doing:
% [ sig1  sig2  sig3   ] .* [ sig1
%                             sig2
%                             sig3 ]
% 
% where we use element-wise multiplication to replicate:
%
% [ sig1  sig1  sig1   ] * [ sig1   0     0
% [ sig2  sig2  sig2   ]   [ 0      sig2  0
% [ sig3  sig3  sig3   ]   [ 0      0     sig3 ]
% 
% to construct the one on the right, we do:
% 
% [sig1 sig2 sig3 ] .* I
% 
% or: u.*eye(3)
% 
% these are the same thing:
% [u; u; u]'*(u.*eye(3))
% [u; u; u]'.*u*eye(3)    % this is just the next one times the identiy matrix
% [u; u; u]'.*u
% u.*u'
% 
% C     = corr([tau,phi,N]);
% CV    = [u; u; u]'*eye(3).*u.*C
% CV    = [u; u; u]'.*u.*C
% CV     = u.*u'.*C

% % this shows how to recover the individual uncerts from the covariance
% matrxi
% u = [ 0.1 0.2 0.3; 
%       0.5 0.6 0.7;
%       0.4 0.8 0.9 ];
%    
% Ix  = [1; 0; 0];
% Iy  = [0; 1; 0];
% Iz  = [0; 0; 1];
% 
% uxx = Ix'*u*Ix
% uyy = Iy'*u*Iy
% uzz = Iz'*u*Iz

% uzz\(Ix'*u)







