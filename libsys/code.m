function varargout = code(cmd)
%CODE pass cmd to vscode to open a project (cmd is a path)
% 
%  msg = CODE(cmd) tries to open the folder or filename CMD in VSCode
% 
% Matt Cooper, 09-Feb-2023, https://github.com/mgcooper
% 
% See also

% arguments
%    cmd (:,:) char
% end

% [~,codesource] = system('which vscode')

if nargin < 1
   cmd = '.';
end

try
   msg = system(['/usr/local/bin/code ' cmd]);
catch
   error('attempt to open current folder in vscode failed')
end

if nargout == 1
   varargout{1} = msg;
end