function Y = functemplate(X,varargin)
%FUNCNAME general description of function
%
%  Y = FUNCNAME(X) description
%  Y = FUNCNAME(X,'name1',value1) description
%  Y = FUNCNAME(X,'name1',value1,'name2',value2) description
%  Y = FUNCNAME(___,method). Options: 'flag1','flag2','flag3'.
%        The default method is 'flag1'.
%
% Example
%
%
%
% Copyright (c) YYYY, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper
%
% See also

%% main code

% parse inputs
[X,option,namevalue] = parseinputs(mfilename, X, varargin{:});

% ... main code


% Parse outputs
% [varargout{1:nargout}] = dealout(argout1, argout2)

end

%% local functions


%% parse inputs

function varargout = parseinputs(funcname, X, varargin)

[varargin{:}] = convertStringsToChars(varargin{:});

% Import the validationModule and add optional argument validation function
f = validationModule;
validoptions = {'a','b'};
f.validOption = @(x)~isempty(validatestring(x,validoptions));

% Create the input parser
p = magicParser; %#ok<*NODEF,*USENS>
p.FunctionName = funcname;
p.CaseSensitive = false;
p.addRequired('X', f.validNumericVector );
p.addOptional('option', 'defaultoption', f.validOption );
p.addParameter('namevalue', false, f.validLogicalScalar );

% Parse the arguments
p.parseMagically('caller');

% Parse outputs
[varargout{1:nargout}] = dealout(X, option, namevalue);

% for backdoor default matlab options, use:
% varargs = namedargs2cell(p.Unmatched);
% then pass varargs{:} as the last argument. but for autocomplete, copy the
% json file arguments to the local one.
end

%% LICENSE

% BSD 3-Clause License
%
% Copyright (c) YYYY, Matt Cooper (mgcooper)
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