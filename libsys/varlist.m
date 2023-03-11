function list = varlist(workspace)
%VARLIST get a list of variables in the workspace ('base' or 'caller')
if nargin < 1
   workspace = 'base';
else
   workspace = validatestring(workspace,{'base','caller'},mfilename,'workspace',1);
end
list = evalin( workspace, 'who' );

% note: who and whos returns the current workspace not the calling workspace

% to see the values of the variables, search online, there are some ways. this
% link is regarding listing values in debug mode:
% https://www.mathworks.com/matlabcentral/answers/100876-is-there-a-way-to-display-the-values-of-all-variables-in-my-workspace-while-debugging-matlab-code