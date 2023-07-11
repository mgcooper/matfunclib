function withjava(func, varargin)
%WITHJAVA Do stuff but only if Java desktop is enabled
%
% Syntax: withjava(func, varargin)
% 
% Input: 
%   func - function handle or name of a function as a char or string
%   varargin - Inputs to the function
%
% Output: 
%   None.
%
% Example: 
%   withjava(@mkdir, "test");
%   withjava('mkdir', "test");
%
% Note:
%   If the MATLAB desktop is not running, a warning is issued and
%   the function is not executed.

if usejava('desktop')
   % Call the function passed in
   if isa(func, 'function_handle')
      func(varargin{:});
   elseif ischar(func) || (isstring(func) && isvector(func))
      try
         func = str2func(func);
         func(varargin{:});
      catch ME
         error('Invalid function name: %s', func);
      end
   else
      error('func must be a function handle or function name');
   end
else
   % warning("%s: editor is not open", func2str(func));
end

end
