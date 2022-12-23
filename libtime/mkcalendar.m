function T = mkcalendar(t1,t2,dt,varargin)
%MKCALENDAR makes a calendar
%
%  T = mkcalendar(t1,t2,dt,varargin)
%
% See also

%--------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = 'mkcalendar';
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

p.addRequired(   't1',                 @(x)isnumeric(x)|isdatetime(x));
p.addRequired(   't2',                 @(x)isnumeric(x)|isdatetime(x));
p.addRequired(   'dt',                 @(x)ischar(x)|isduration(x)|iscalendarduration(x));
p.addParameter(  'TimeZone',  'nan',   @(x)ischar(x));
%p.addParameter(  'TimeZone',  'UTC',   @(x)ischar(x));
p.addParameter(  'noleap',    false,   @(x)islogical(x));
p.parseMagically('caller');
%--------------------------------------------------------------------------

% parse the timestep if a string was passed in
if ischar(dt)
   dt = str2duration(dt,'caltime',true);
end

% build a calendar
T = tocolumn(t1:dt:t2);

% set the time zone
if TimeZone ~= "nan"
   T.TimeZone = TimeZone;
end

% remove leap inds
if noleap == true
   T = rmleapinds(T);
end