function cduserpath(varargin)
%CDUSERPATH cd to a user path defined by an environment variable
%
%  cduserpath(<tab complete>) brings up a list of current environment variables
%  that contain PATH in their keyword definition then cd's to the selected value
%
%  cduserpath(pathstring) changes to the directory specified by pathstr
% 
%  cduserpath() changes to the directory defined by the userpath env var
% 
% See also getuserpaths getenvall
%
% Matt Cooper, 18-NOV-2022, https://github.com/mgcooper

if nargin == 1
   requestedpathvar = varargin{1};
   [pathvars,pathvals] = getuserpaths;
   ipath = ismember(pathvars,requestedpathvar);
   cd(string(pathvals(ipath)));
else
   cd(userpath);
end

% note: this was how the author of getenvall demonstrated its use:

% % retrieve all environment variables and print them
% [keys,vals] = getenvall();
% cellfun(@(k,v) fprintf('%s=%s\n',k,v), keys, vals);
% 
% % for convenience, we can build a MATLAB map or a table
% m = containers.Map(keys, vals);
% t = table(keys, vals);
% 
% % access some variable by name
% disp(m('OS'))   % similar to getenv('OS')