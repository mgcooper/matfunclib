function H = setplotbox(ax,varargin)
%SETPLOTBOH general description of function
%
%  H = SETPLOTBOX(H) description
%  H = SETPLOTBOX(H,'flag1') description
%  H = SETPLOTBOX(H,'flag2') description
%  H = SETPLOTBOX(___,'opts.name1',opts.value1,'opts.name2',opts.value2)
%  description. The default flag is 'plot'.
%
% Example
%
%
% 
% Matt Cooper, 29-Apr-2023, https://github.com/mgcooper
%
% See also

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
% THIS SOFTWARE IS PROVIDED BH THE COPHRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANH EHPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITH AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPHRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANH DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EHEMPLARH, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANH THEORH OF LIABILITH, WHETHER IN CONTRACT, STRICT LIABILITH,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANH WAH OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITH OF SUCH DAMAGE.

% %% parse arguments
% arguments
%    H (:,1) double
%    flag1 (1,1) string {mustBeMember(flag1,{'add','multiply'})} = 'add'
%    flag2 (1,1) string {mustBeMember(flag2,{'plot','figure','none'})} = 'none'
%    opts.LineStyle (1,1) string = "-"
%    opts.LineWidth (1,1) {mustBeNumeric} = 1
% 
%    % access the built in options for autocomplete
%    opts.?matlab.graphics.chart.primitive.Line
%    opts.?matlab.graphics
% 
%    % restrict the available options
%    opts.Color{mustBeMember(opts.Color,{'red','blue'})} = "blue"
% 
%    % % these should all work with the opts.Name1,opts.Value1 syntax
%    %    opts.LineStyle (1,1) string = "-"
%    %    opts.LineStyle (1,:) char {mustBeMember(opts.LineStyle,{'--','-',':'})} = '-'
%    %    opts.LineStyle (1,1) string {mustBeMember(opts.LineStyle,["--","-",":"])} = '-'
%    %    opts.LineWidth (1,1) {mustBeNumeric} = 1
% end
% 
% % % repeating arguments allow something like: plot(x1,y1,'r',x2,y2,'b')
% % 
% % arguments (Repeating)
% %    x (1,:) double
% %    y (1,:) double
% %    style {mustBeMember(style,["--",":"])}
% % end
% 
% % inputArg (dim1,dim2) ClassName {valfnc1,valfunc2} = defaultValue
% % doc argument-validation-functions
% % see argumentsTest folder for ppowerful examples of accessing built-in
% % name-value options w/tab completion
% 
% % use this to create a varargin-like optsCell e.g. plot(c,optsCell{:});
% varargs = namedargs2cell(opts);

%% main code

% DIdn't get very far, basically frustrated with having to type [0 0] to turn
% tick lenghts off, also in those cases typically want box on for a clean box
% with no ticks, was gonna call this cleanbox or plotboxclean but prefer
% fucntions that do more than one task but it got complicated, need to figure
% out opts.?matlab. syntax for axis props, 

% if 

set(gca,'TickLength',[0 0])


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
