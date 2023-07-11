function f = validationModule(varargin)
%VALIDATIONMODULE validation function module
% 
%  f = validationModule Returns scalar struct array f containing function
%  handles to validate function inputs. Designed for inputParser. For argument
%  block, use built-in mustBe* functions.
% 
% Example
% f = validationModule;
% f.validChar(1)
% f.validChar('a')
% f.validAxis(1)
% f.validAxis(gca)
% 
% Matt Cooper, 26-Apr-2023, https://github.com/mgcooper
% 
% See also inputParser

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

% Main

% Store all local functions in f, get the function names, convert to a struct
% array with function name fieldnames, and instantiate the functions
f = localfunctions;
f = structfun(@(x) x(),cell2struct(f,cellfun(@func2str,f,'uni',0),1),'uni',0);

end

%% Validation Function Library

% function f = validOptionalArgument
% % f = @(x,y) ~isempty(validatestring(x,y));
% f = @(x) ~isempty(validatestring(x,validstring));
% end

% % For reference, this works
% F = {f.validTableLike, f.validNumericArray};
% p.addRequired('Data', @(x) any(arrayfun( @(n) F{n}(x), 1:numel(F))));
% p.addRequired('Data', @(x) any(cellfun(@(f) f(x),F)));

% % 17 May added this, need to check - nope, won't work, inspired by
% PeakFlowsModule where I realized how to build a structfun function that takes
% an input which hasn't been created yet, see threshpeaks, but doesn't work in
% this case b/c we need to pass in the argument and the table
% function f = validTableVariable
% f = @(x) ismember(x.Properties.VariableNames);
% 
% f = @(x) cellfun(@(y) ismember(y,x), x.Properties.VariableNames);
% end

function f = validAxis
f = @(x) isa(x,'matlab.graphics.axis.Axes');
end

function f = validErrorBar
f = @(x) isa(x,'matlab.graphics.chart.primitive.ErrorBar');
end

function f = validChar
f = @(x) ischar(x) ;
end

function f = validString
f = @(x) ischar(x) ;
end

function f = validCharLike
f = @(x) ischar(x) | isstring(x) | iscellstr(x) ;
end

function f = validDateLike
f = @(x) isdatetime(x) | isnumeric(x) & isvector(x);
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

function f = validTableLike
f = @(x) istable(x) | istimetable(x) ;
end