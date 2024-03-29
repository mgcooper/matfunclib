function varargout = regression_tricks(varargin)
%REGRESSION_TRICKS regression tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%%

% check out the SPIDER toolsbox:
% http://people.kyb.tuebingen.mpg.de/spider/whatisit.html

% i need to compare the result of my yorkfit with the pca analysis linked
% below and with multivariate regression using an error term as an
% additional variable

% https://www.mathworks.com/help/stats/fitting-an-orthogonal-regression-using-principal-components-analysis.html


% % something i was following online, need to file away somewhere
% x = data.x;
% xones = ones(size(x));
% X = [xones,x];
% ab = X\y
% ab = inv((X'*X))*X'*y
% ab = inv((x'*x))*x'*y



% I alwasy get confused by this so for reference:
% this works:  [1 2] * [ones(1,10) ; rand(1,10)]
% this works:  [1 2; 1 2; 1 2] * [ones(1,10) ; rand(1,10)]
% this doesnt: [1 2; 1 2; 1 2] * rand(3,1)
% this works:  [1 2; 1 2; 1 2]' * rand(3,1)
% this works:  [1 2; 1 2; 1 2] .* rand(3,1)
% this doesnt: [1; 2] * [ones(1,10);rand(1,10)]
% the first one is standard linear regression type matrix multiplication: 
% [a b] * [ 1  1  1  ]  =  [ a + b*t1 ]
%         [ t1 t2 t3 ]     [ a + b*t2 ]
%                          [ a + b*t3 ]
%                          
% the second one is two-linear regressions 
% [a1 b1] * [ 1  1  1  ]  =   [ a1 + b1*t1 ]
% [a2 b2]   [ t1 t2 t3 ]      [ a2 + b2*t1 ]
% [a3 b3]                     [ a3 + b3*t1 ]
%                             [ a1 + b1*t2 ]
%                             [ a2 + b2*t2 ]
%                             [ a3 + b3*t2 ]
%                             [ a1 + b1*t3 ]
%                             [ a2 + b2*t3 ]
%                             [ a3 + b3*t3 ]






