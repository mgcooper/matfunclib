function tspan = timespan(T,varargin)
%TIMESPAN return time span of timetable, datetime, or duration object T 
% 
% Syntax
% 
%  tspan = TIMESPAN(T) returns the time spanned by T
%  tspan = TIMESPAN(T,'name1',value1)
%  tspan = TIMESPAN(T,'name1',value1,'name2',value2)
%  tspan = TIMESPAN(___,method). Options: 'flag1','flag2','flag3'.
%        The default method is 'flag1'. 
% 
% Matt Cooper, 29-Nov-2022, https://github.com/mgcooper
% 
% See also

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = 'timespan';
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

% validstrings      = {''}; % or [""]
% validoption       = @(x)any(validatestring(x,validstrings));

p.addRequired(    'T',                    @(x)isdatetime(x)||istimetable(x)||isduration(x));
% p.addOptional(    'option',      nan,     validoption          );
% p.addParameter(   'namevalue',   false,   @(x)islogical(x)     );

p.parseMagically('caller');

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%------------------------------------------------------------------------------

if istimetable(T)
   T = settimetabletimevar(T);
   Time = T.Time;
elseif isdatetime(T)
   Time = T;
elseif isduration(T) || iscalendarduration(T)
   % not currently supported
end

tspan = [Time(1) Time(end)];












