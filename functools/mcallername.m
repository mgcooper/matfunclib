function varargout = mcallername(varargin)
   %MCALLERNAME Get the name of the calling function on the stack
   %
   %  MSG = MCALLERNAME() returns char MSG, the name of the bottom-most function
   %  on the stack. If called from the base workspace, MSG is returned as an
   %  empty array [].
   %
   %  MSG = MCALLERNAME(FILEOPTION) returns the full path to the function for
   %  the prior calling syntaxes if FILEOPTION 'fullpath', the filename without
   %  the full path but including the .m extension if FILEOPTION 'filename', and
   %  the function name (filename without .m extension) if FILEOPTION is
   %  'funcname'. The default FILEOPTION is 'funcname'.
   %
   %  MSG = MCALLERNAME(_, 'STACKLEVEL', RELATIVE_LEVEL) returns the name of the
   %  function on the stack at RELATIVE_LEVEL, the number of stack levels below
   %  this function. If RELATIVE_LEVEL = 1, the caller of this function is
   %  returned. If RELATIVE_LEVEL = 2, the caller of that function is returned.
   %  Default value is If RELATIVE_LEVEL = N-1, where N = numel(dbstack), and -1
   %  accounts for this function.
   %
   %
   % The stack goes from this file on top to the base workspace on bottom. If
   % this function is called from the command line, stack(1) = this file. If
   % called from a function, stack(1) = this file, stack(2) = caller. If called
   % from a function that was called by another function, stack(1) = this file,
   % stack(2) = caller of this function, stack(3) = caller of that function.
   %
   % The normal use case is to call this from at least two functions deep (third
   % example above). That is, the bottom-most function in the stack calls
   % another function, within which it is useful to know the calling function
   % name. This allows that calling function to be found without passing around
   % mfilename.
   %
   % See also mfilename, mfoldername

   % input checks
   narginchk(0,Inf)

   % get the stack
   stack = dbstack('-completenames');

   % early exit if called from command line
   if numel(stack) == 1
      msg = [];

   else
      N = numel(stack);

      % parse inputs
      [stacklevel, fileoption] = parseinputs(N, mfilename, varargin{:});

      % parse the stack
      switch fileoption
         case 'fullpath'

            msg = stack(stacklevel).file;

         case 'filename'

            [~, msg, ext] = fileparts(stack(stacklevel).file);
            msg = [msg ext];

         otherwise % case 'funcname'

            msg = stack(stacklevel).name;
      end
   end

   if nargout <= 1
      varargout{1} = msg;
   elseif nargout > 1
      error([mfilename ' expected at most one output argument'])
   end
end

%% parse inputs
function [stacklevel, fileoption] = parseinputs(N, funcname, varargin)

   [varargin{:}] = convertStringsToChars(varargin{:});

   validopt = {'fullpath', 'filename', 'funcname'};

   % create parser
   p = inputParser;
   p.FunctionName = funcname;
   p.addOptional('fileoption', 'funcname', @(x) ~isempty(validatestring(x, validopt)));
   p.addParameter('stacklevel', N, @(x) isnumericscalar(x));
   p.parse(varargin{:})
   stacklevel = p.Results.stacklevel;
   fileoption = p.Results.fileoption;
end

% set defaults
% stacklevel = numel(stack);
% fileoption = 'funcname';
%
% for n = 1:numel(varargin)
%
% end
%
% switch nargin
%    case 1
%       if isnumeric(varargin{1})
%          stacklevel = varargin{1};
%          validateattributes(varargin{cellfun(@isnumeric, varargin)}, ...
%             {'numeric', 'scalar'}, {'nonempty'}, funcname, 'stacklevel', 3)
%       else
%          fileoption = validatestring(varargin{cellfun(@ischar, varargin)}, ...
%             {'fullpath', 'filename', 'funcname'}, funcname, 'fileoption');
%       end
% end

% % This one is basically functional

% if nargin == 1, varargin{1} can be fileoption or stacklevel. If it is
% fileoption, then validatestring will catch it

% fileoption = validatestring(varargin{cellfun(@ischar, varargin)}, ...
%    {'fullpath', 'filename', 'funcname'}, mfilename, 'fileoption');
%
% if nargin == 1 && isempty(fileoption)
%    stacklevel = varargin{1};
% elseif nargin == 2
%    stacklevel = varargin{2};
% end
%
% validateattributes(stacklevel, {'numeric', 'scalar'}, ...
%    {'nonempty'}, funcname, 'stacklevel', 3)
%
% % validateattributes(varargin{cellfun(@isnumeric, varargin)}, ...
% %    {'numeric', 'scalar'}, {'nonempty'}, funcname, 'stacklevel', 3)
%
% % set defaults
% stacklevel = numel(stack);
% fileoption = 'funcname';

%% LICENSE

% BSD 3-Clause License
%
% Copyright (c) 2023, Matt Cooper (mgcooper)
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
