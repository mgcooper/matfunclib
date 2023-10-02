function f = validationModule(varargin)
   %VALIDATIONMODULE Create module of validation functions for argument parsing
   %
   %  F = validationModule() Returns struct array F containing function handles
   %  to validation functions. Can be used for general-purpose logical
   %  validation, especially type-checking. Designed for inputParser. For
   %  argument blocks, use built-in mustBe* functions. F is a scalar struct.
   %
   % % Example 1: general purpose logical checks
   % ------------
   %
   % f = validationModule;
   % f.validChar(1)
   % f.validChar('a')
   % f.validAxis(1)
   % f.validAxis(gca)
   %
   % % Example 2: inputParser optioanl argument validation
   % ------------
   %
   % % Define valid menu of optional arguments
   % menu = {'add','multiply'};
   %
   % % Import the validationModule and create the input parser
   % f = validationModule();
   % p = inputParser();
   %
   % % Add an optional argument, and a name-value parameter
   % p.addOptional('option', 'add', @(opt) f.validOptionalArgument(opt, menu));
   % p.addParameter('parameter', false, f.validLogicalScalar );
   %
   % % Parse the arguments
   % p.parse('add', 'parameter', true);
   % option = p.Results.option
   % value = p.Results.parameter
   %
   %
   % % Example 3: inputParser validation using multiple validation functions
   % ------------
   %
   % % Import the validation module
   % f = validationModule();
   %
   % % Concatenate the validation functions you'd like to pass to the parser. In
   % this % case, the argument DATA can be a table, timetable, or a numeric
   % array
   % F = {f.validTableLike, f.validNumericArray};
   %
   % % Pass that to the inputParser using cellfun to apply each function in F to
   % DATA 
   % p.addRequired('Data', @(x) any(cellfun(@(f) f(x),F)));
   %
   % % arrayfun also works but the syntax is less clear
   % p.addRequired('Data', @(x) any(arrayfun( @(n) F{n}(x), 1:numel(F))));
   %
   % Notes
   %
   % Although the following syntax is valid:
   %     f = @ischar ; f('a')
   %
   % validationModule uses the following convention:
   %     f = @(x) ischar(x) ; f('a')
   %
   % Note that the following would support multi-valued validation:
   %     f = @(varargin) cellfun(@ischar, varargin); tf = f('a','b')
   %     f = @(varargin) cellfun(@ischar, varargin); tf = f('a',5)
   %
   % Multi-valued validation is not currently supported.
   %
   % Matt Cooper, 26-Apr-2023, https://github.com/mgcooper
   %
   % See also inputParser

   % TODO: review content of functiontests it is relevant to module concept
   % notice the custom validation subfunctions - reminder to see if a single
   % parser per project is possible
   % if so, prob need a validationModule per project as well

   % Main

   % Store all local functions in f, get the function names, convert to a struct
   % array with function name fieldnames, and instantiate the functions
   f = localfunctions;
   f = structfun(@(x) x(),cell2struct(f,cellfun(@func2str,f,'uni',0),1),'uni',0);

   % For reference:
   % info = functions(f.validAxis);

end

%% Validation Function Library

function f = validAxis
   f = @(x) isa(x,'matlab.graphics.axis.Axes');
end

function f = validErrorBar
   f = @(x) isa(x,'matlab.graphics.chart.primitive.ErrorBar');
end

function f = validChar
   f = @(x) ischar(x) ;

   % This works, but more testing is needed before this is adopted module-wide
   % f = @(varargin) cellfun(@ischar, varargin);
end

function f = validString
   f = @(x) isstring(x) ;
end

function f = validCharLike
   f = @(x) isstring(x) || iscellstr(x) || ...
      ( ischar(x) && isrow(x) || isequal(x, '') );
end

function f = validDateLike
   f = @(x) isdatetime(x) || iscalendarduration(x) || isduration(x) || ...
      istimetable(x) || ( isnumeric(x) && isvector(x) && all(x>=0)) ;
end

function f = validDateTime
   f = @(x) isdatetime(x) ;
end

function f = validNumericScalar
   f = @(x) isnumeric(x) && isscalar(x) ;
end

function f = validNumericVector
   f = @(x) isnumeric(x) && isvector(x) ;
end

function f = validNumericArray
   f = @(x) isnumeric(x) && ismatrix(x) ;
end

function f = validNumericMatrix
   f = @(x) isnumeric(x) && ismatrix(x) && ~isvector(x) ;
end

function f = validDoubleScalar
   f = @(x) isa(x,'double') && isscalar(x) ;
end

function f = validDoubleVector
   f = @(x) isa(x,'double') && isvector(x) ;
end

function f = validDoubleArray
   f = @(x) isa(x,'double') && ismatrix(x) ;
end

function f = validDoubleMatrix
   f = @(x) isa(x,'double') && ismatrix(x) && ~isvector(x) ;
end

function f = validSingleScalar
   f = @(x) isa(x,'single') && isscalar(x) ;
end

function f = validSingleVector
   f = @(x) isa(x,'single') && isvector(x) ;
end

function f = validSingleArray
   f = @(x) isa(x,'single') && ismatrix(x) ;
end

function f = validSingleMatrix
   f = @(x) isa(x,'single') && ismatrix(x) && ~isvector(x) ;
end

function f = validLogicalScalar
   f = @(x) islogical(x) && isscalar(x) ;
end

function f = validLogicalVector
   f = @(x) islogical(x) && isvector(x) ;
end

function f = validLogicalMatrix
   f = @(x) islogical(x) && ismatrix(x) && ~isvector(x) ;
end

function f = validTabular
   f = @(x) istable(x) || istimetable(x) ;
end

function f = validOptionalArgument

   f = @(opt, menu) ~isempty(validatestring(opt, menu));

   % Notes
   %
   % Below is a list of methods that work. The one above seems clearest, although
   % 'menu' is somewhat vague, whereas varargin is a known function.
   %
   % f = @(opt, menu) ~isempty(validatestring(opt, menu));                   % 1.
   % f = @(varargin) ~isempty(validatestring(varargin{1}, varargin{2}));     % 2.
   % f = @(opt, varargin) ~isempty(validatestring(opt, varargin{1}));        % 3.
   % f = @(opt, varargin) ~isempty(validatestring(opt, varargin{:}));        % 4.
   %
   % When the inputParser is defined like this:
   %
   % menu = {'add','multiply'};
   % p.addOptional('option','add', @(opt) f.validOptionalArgument(opt, menu));
   %
   % And a break point is placed on the parse step, and you step in here:
   %
   % 1.         opt = 'add',        menu = 1x2 cell: {'add'} {'multiply'}
   % 2. varargin{1} = 'add', varargin{2} = 1x2 cell: {'add'} {'multiply'} (varargin = {1x2} cell)
   % 3.         opt = 'add', varargin{1} = 1x2 cell: {'add'} {'multiply'} (varargin = {1x1} cell)
   % 4.         opt = 'add', varargin{:} = 1x2 cell: {'add'} {'multiply'} (varargin = {1x1} cell)
   %
   % So they all work b/c 'opt' = 'add' and 'menu' = 1x2 cell array of valid opts
   % as expected by validatestring.
   %
   % These do not work:
   %
   % f = @(opt) ~isempty(validatestring(opt, menu));                         % 1.
   % f = @(varargin) ~isempty(validatestring(varargin{1},varargin(2:end)));  % 2.
   % f = @(opt, menu) ~isempty(validatestring(opt, menu{:}));                % 3.
   %
   % 1. fails , see below
   % 2. varargin{1} = 'add', varargin(2:end) = {1x2 cell}, varargin{2} = 1x2 cell: ({'add'} {'multiply'}
   % 3.         opt = 'add',     menu{:} = 1x2 comma separated list: 'add', 'multiply'
   %
   % Explanation for why they fail:
   % 1. fails b/c f is a function of 'opt' so it knows nothing about 'menu'
   % 2. fails b/c validatestring doesn't unpack the {1x2 cell}
   % 3. fails because menu is a comma separated list, Note: this means it fails
   % because validatestring (not inputParser) expects a string array or cell array of chars
   %
   %
   % Things do not work when the inputParser is defined like this:
   %
   % p.addOptional('option','add', @(opt, menu) f.validOptionalArgument(opt, menu));
   %
   % The 'parse' step fails, I believe the failure is at the addOptional step
   % and has nothing to do with f.validOptionalArgument. I think inputParser
   % requires that the second argument passed to addOptional is scalar, and it
   % passes that to the validation function. I tried this syntax to test that,
   % but it failed:
   %
   % p.addOptional('option',{'add', menu}, @(opt, menu) f.validOptionalArgument(opt, menu)); 
   %

   % Using cellfun might help in some of the case above
   % f = @(varargin) cellfun(@ischar, varargin);

end

% Below does not work, see PeakFlowsModule where I build a structfun function
% that takes an input which hasn't been created yet (see threshpeaks). It
% doesn't work in this case b/c we need to pass in the argument and the table
%
% Note, this might just need varargin instead of x,y
%
% function f = validTableVariable
% f = @(x) ismember(x.Properties.VariableNames);
%
% f = @(x) cellfun(@(y) ismember(y,x), x.Properties.VariableNames);
% end

%% LICENSE
%
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