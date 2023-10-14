function varargout = functemplate(X,flag,folder,style,localopts,fromclass)
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

   % PARSE ARGUMENTS
   arguments
      X (:,1) double
      flag (1,1) string {mustBeMember(flag,{'add','multiply'})} = 'add'
      folder (1,:) string {mustBeFolder} = string.empty

      % define local optional argument
      style {mustBeMember(style,["--",":","-"])} = "-"

      % define local name-value pairs
      localopts.Silent (1,1) logical = false
      localopts.LineStyle (1,1) string {mustBeMember(localopts.LineStyle,["--","-",":"])} = '-'
      localopts.LineWidth (1,1) {mustBeNumeric} = 1

      % pull name-value pairs from classdef
      fromclass.?matlab.graphics.chart.primitive.Line
      % for ?syntax call metaclass on the object:
      % mc=metaclass(line()),name=mc.Name
      
      % override a default property:
      fromclass.Color {mustBeMember(fromclass.Color,{'red','blue'})} = "blue"
   end

   % get the class defaults
   fromclass = metaclassDefaults(fromclass, ?matlab.graphics.chart.primitive.Line);

   % use this to create a varargin-like optsCell e.g. plot(c,optsCell{:});
   args = namedargs2cell(opts);

   % use this to convert an opts.name = val struct to "name=val" string
   args = optionsToNamedArguments(optsstruct);

   % MAIN CODE
   cleanup = onCleanup(@() cleanupfunc());

   % To add to functemplate: failures = MException.empty;

   % CHECKS
   assert()

   % PARSE OUTPUTS
   nargoutchk(0, Inf)
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
