function [val,idx] = findnearest(X,target,varargin)
%FINDNEAREST general description of function
% 
%  Y = FINDNEAREST(X) description
%  Y = FINDNEAREST(X,'name1',value1) description
%  Y = FINDNEAREST(X,'name1',value1,'name2',value2) description
%  Y = FINDNEAREST(___,method). Options: 'flag1','flag2','flag3'.
%        The default method is 'flag1'. 
% 
% Example
%  
% 
% Matt Cooper, 16-Feb-2023, https://github.com/mgcooper
% 
% See also

% input parsing
[X, target, n] = parseinputs(X, target, funcname, varargin{:});

% findnearest
idx = find(min(abs(X-target))==abs(X-target),n,'first');
val = X(idx);


% parse inputs
function [X, target, n] = parseinputs(X, target, funcname, varargin)
p = inputParser;
p.FunctionName = funcname;
p.CaseSensitive = false;
p.KeepUnmatched = true;  

p.addRequired( 'X', @(x)isnumeric(x) | isdatetime(x));
p.addRequired( 'target', @(x)isnumeric(x) | isdatetime(x));
p.addOptional( 'n', 1, @(x)isnumericscalar(x));

p.parse(X,target,varargin{:});

X = p.Results.X;
target = p.Results.target;
n = p.Results.n;







