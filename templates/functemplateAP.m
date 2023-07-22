function varargout = functemplate(X,flag,style,opts)
%FUNCNAME general description of function
%
%  Y = FUNCNAME(X) description
%  Y = FUNCNAME(X,'flag') description
%  Y = FUNCNAME(_,'opts.name1',opts.value1,'opts.name2',opts.value2)
%
% Example
%
%
% Copyright (c) YYYY, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper
%
% See also


% PARSE ARGUMENTS
arguments
   X (:,1) double
   flag (1,1) string {mustBeMember(flag,{'add','multiply'})} = 'add'
   style {mustBeMember(style,["--",":","-"])} = "-"
   opts.LineStyle (1,1) string {mustBeMember(opts.LineStyle,["--","-",":"])} = '-'
   opts.LineWidth (1,1) {mustBeNumeric} = 1
   opts.Color{mustBeMember(opts.Color,{'red','blue'})} = "blue" % restrict options
   opts.?matlab.graphics.chart.primitive.Line
   % for ?syntax call metaclass on the object: mc=metaclass(line()),name=mc.Name
end

% use this to create a varargin-like optsCell e.g. plot(c,optsCell{:});
args = namedargs2cell(opts);

% use this to convert an opts.name = val struct to "name=val" string
args = optionsToNamedArguments(optsstruct);

% https://www.mathworks.com/matlabcentral/answers/760546-function-argument-validation-from-class-properties-ignores-defaults

% MAIN CODE


% PARSE OUTPUTS
[varargout{1:nargout}] = dealout(argout1, argout2);

end

%% LOCAL FUNCTIONS


%% TESTS

%!test

% ## add octave tests here

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