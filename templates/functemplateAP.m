function Y = functemplate(X,flag1,flag2,opts)
%FUNCNAME general description of function
%
%  Y = FUNCNAME(X) description
%  Y = FUNCNAME(X,'flag1') description
%  Y = FUNCNAME(X,'flag2') description
%  Y = FUNCNAME(___,'opts.name1',opts.value1,'opts.name2',opts.value2)
%  description. The default flag is 'plot'.
%
% Example
%
%
% 
% Matt Cooper, DD-MMM-YYYY, https://github.com/mgcooper
%
% See also

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

%% parse arguments
arguments
   X (:,1) double
   flag1 (1,1) string {mustBeMember(flag1,{'add','multiply'})} = 'add'
   flag2 (1,1) string {mustBeMember(flag2,{'plot','figure','none'})} = 'none'
   opts.LineStyle (1,1) string = "-"
   opts.LineWidth (1,1) {mustBeNumeric} = 1

   % access the built in options for autocomplete. For unknown class names,
   % create the object e.g. h = line(1,1), mc = metaclass(h), name = mc.Name
   opts.?matlab.graphics.chart.primitive.Line

   % restrict the available options
   opts.Color{mustBeMember(opts.Color,{'red','blue'})} = "blue"

   % % these should all work with the opts.Name1,opts.Value1 syntax
   %    opts.LineStyle (1,1) string = "-"
   %    opts.LineStyle (1,:) char {mustBeMember(opts.LineStyle,{'--','-',':'})} = '-'
   %    opts.LineStyle (1,1) string {mustBeMember(opts.LineStyle,["--","-",":"])} = '-'
   %    opts.LineWidth (1,1) {mustBeNumeric} = 1
end

% % repeating arguments allow something like: plot(x1,y1,'r',x2,y2,'b')
% 
% arguments (Repeating)
%    x (1,:) double
%    y (1,:) double
%    style {mustBeMember(style,["--",":"])}
% end

% inputArg (dim1,dim2) ClassName {valfnc1,valfunc2} = defaultValue
% doc argument-validation-functions
% see argumentsTest folder for ppowerful examples of accessing built-in
% name-value options w/tab completion

% Return to this:
% https://www.mathworks.com/matlabcentral/answers/760546-function-argument-validation-from-class-properties-ignores-defaults

% use this to create a varargin-like optsCell e.g. plot(c,optsCell{:});
varargs = namedargs2cell(opts);

%% main code

end

%% local functions

% % picked this up from addCodeTrace
% optionsToNamedArguments(options)
%
% function s = optionsToNamedArguments(options)
%     names = string(fieldnames(options));
%     s = strings(length(names),1);
%     for k = 1:length(names)
%         name = names(k);
%         value = options.(name);
%         if isstring(value)
%             s(k) = name + "=" + """" + value + """";
%         elseif isnumeric(value) || islogical(value)
%             s(k) = name + "=" + value;
%         end
%     end
%     s = join(s,",");
% end

% But this might work too:

% function nameval = struct2nameval(value)
% % Collapses a name-value struct into comma and colon markup.
% %
% %   str = map2str(value)
% %
% % STRUCT2NAMEVAL examples:
% %   s = struct()        ->  ""
% %   s.Name1 = "Value1"  ->  "Name1=Value1"
% %   s.Name2 = "Value2"  ->  "Name1=Value1,Name2=Value2"
% 
% arguments
%    value (1, 1) struct
% end
% 
% fcn = @(f) compose("%s=%s", f, format(value.(f)));
% nameval = strjoin(cellfun(fcn, fieldnames(value)), ",");
% 
% function s = format(v)
%    if isnumeric(v)
%       s = string(num2str(v));
%    elseif not(isscalar(v))
%       s = arrayfun(@format, v);
%    elseif ismissing(v)
%       s = "<missing>";
%    else
%       s = string(v);
%    end
% 
%    if not(isscalar(v))
%       s = "[" + s + "]";
%    end
% end
% 
% end