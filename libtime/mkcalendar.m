function T = mkcalendar(t1,t2,dt,varargin)
%MKCALENDAR 
%--------------------------------------------------------------------------
   p                 = MipInputParser;
   p.FunctionName    = 'mkcalendar';
   p.CaseSensitive   = false;
   p.KeepUnmatched   = true;

   p.addRequired(   't1',                 @(x)isnumeric(x)|isdatetime(x));
   p.addRequired(   't2',                 @(x)isnumeric(x)|isdatetime(x));
   p.addRequired(   'dt',                 @(x)ischar(x)|isduration(x));
   p.addParameter(  'TimeZone',  'UTC',   @(x)ischar(x));
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
   T.TimeZone = TimeZone;

   % remove leap inds
   if noleap == true
      T = rmleapinds(T);
   end