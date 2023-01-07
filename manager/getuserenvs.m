function env = getuserenvs(varargin)
%GETUSERENVS get a user-defined environment variable or a list of all
%environment variables
%
%  env = getuserenvs(<tab complete>) brings up a list of current environment
%  variables for the user to select and returns the selected variable as a
%  string 'env'. 
%
%  env = getuserenvs() returns a cellstr array of all current environment
%  variables 
% 
% 
% See also getuserpaths getenvall
%
% Matt Cooper, 23-Nov-2022, https://github.com/mgcooper

if nargin == 1
   env = varargin{1};
   env = getenv(env);
else
   [keys,vals] = getenvall;
   env = table(keys,vals);
end