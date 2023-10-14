function varargout = validatemat(A, classes, attributes, varargin)
   %VALIDATEMAT validate array
   %
   % A = validatemat(A,classes,attributes)
   % A = validatemat(A,classes,attributes,argIndex)
   % A = validatemat(A,classes,attributes,funcName)
   % A = validatemat(A,classes,attributes,funcName,varName)
   % A = validatemat(A,classes,attributes,funcName,varName,argIndex)
   %
   % Example
   %
   %
   % Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, github.com/mgcooper
   %
   % See also
   
   % NOT FUNCTIONAL

   % PARSE INPUTS
   narginchk(3, 6)

   % [varargin{:}] = convertStringsToChars(varargin{:});

   argIndex = [];
   funcName = [];
   varName = [];

   if nargin > 3

      if isnumeric(varargin{1})
         validateattributes(varargin{1}, {'numeric'}, {'scalar'}, mfilename, ...
            'ARGINDEX', 4);
         argIndex = varargin{1};

      else
         validateattributes(varargin{1}, {'char'}, {'scalartext'}, mfilename, ...
            'FUNCNAME', 4);
         funcName = varargin{1};
      end


      if nargin > 4
         validateattributes(varargin{1}, {'char'}, {'scalartext'}, mfilename, ...
            'VARNAME', 5);
         varName = varargin{2};
      end

      if nargin > 5
         validateattributes(varargin{1}, {'numeric'}, {'scalar'}, mfilename, ...
            'ARGINDEX', 6;
         argIndex = varargin{3};
      end

   end

   % MAIN CODE
   cleanup = onCleanup(@() cleanupfunc());

   % finish this, then use tf to return A ... or think about whether validatestring
   % could be adopted with ismember
   tf = validateattributes(A, classes, attributes, )

   % PARSE OUTPUTS
   [varargout{1:nargout}] = dealout(argout1, argout2);

end

%% LOCAL FUNCTIONS
function cleanupfunc

end

%% TESTS

%!test

% ## add octave tests here

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
