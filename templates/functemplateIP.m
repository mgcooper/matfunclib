function varargout = functemplate(X, varargin)
   %FUNCNAME One line description of function.
   %
   % Syntax
   %  Y = FUNCNAME(X)
   %  Y = FUNCNAME(X, 'flag')
   %  Y = FUNCNAME(_, 'opts.name1', opts.value1, 'opts.name2', opts.value2)
   %
   % Description
   %  Y = FUNCNAME(X) description.
   %  Y = FUNCNAME(X,'flag') description.
   %  Y = FUNCNAME(_, 'opts.name1', opts.value1, 'opts.name2', opts.value2)
   %
   % Example
   %
   %
   % Input Arguments
   %
   %
   % Output Arguments
   %
   %
   % Copyright (c) YYYY, Matt Cooper, BSD 3-Clause License, github.com/mgcooper
   %
   % See also:

   % PARSE INPUTS
   [X, option, namevalue] = parseinputs(mfilename, X, varargin{:});

   % MAIN CODE
   cleanup = onCleanup(@() cleanupfunc());

   % CHECKS
   assert()

   % PARSE OUTPUTS
   nargoutchk(0, Inf)
   [varargout{1:nargout}] = dealout(argout1, argout2);
end

%% LOCAL FUNCTIONS
function cleanupfunc

end

%% INPUT PARSER
function varargout = parseinputs(funcname, X, varargin)
   %PARSEINPUTS Parse input arguments.

   [varargin{:}] = convertStringsToChars(varargin{:});

   % Define valid menu of optional arguments
   menu = {'add', 'multiply'};

   % Create the input parser and import the validationModule
   f = validationModule();
   persistent parser
   if isempty(parser)
      parser = inputParser();
      parser.addRequired('X', f.validNumericVector );
      parser.addOptional('option', 'add', @(opt) f.validOptionalArgument(opt, menu));
      parser.addParameter('namevalue', false, f.validLogicalScalar );
   end
   parser.FunctionName = funcname;
   parser.parse(X, varargin{:});
   option = parser.Results.option;
   namevalue = parser.Results.namevalue;

   % Parse outputs
   [varargout{1:nargout}] = dealout(X, option, namevalue);

   % for backdoor default matlab options, use:
   % varargs = namedargs2cell(p.Unmatched);
   % then pass varargs{:} as the last argument. but for autocomplete, copy the
   % json file arguments to the local one.

end

%% TESTS

%!test

% ## add octave tests here

%% LICENSE

% BSD 3-Clause License
%
% Copyright (c) YYYY, Matt Cooper (mgcooper) All rights reserved.
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
%    contributors may be used to endorse or promote products derived from this
%    software without specific prior written permission.
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
