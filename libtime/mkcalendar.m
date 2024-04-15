function T = mkcalendar(t1,t2,dt,varargin)
   %MKCALENDAR makes a calendar
   %
   %  T = mkcalendar(t1,t2,dt)
   %  T = mkcalendar(t1,t2,dt,'noleap')
   %  T = mkcalendar(t1,t2,dt,'TimeZone','UTC')
   %  T = mkcalendar(t1,t2,dt,'noleap','TimeZone','UTC')
   %
   % See also

   % parse inputs
   [t1, t2, dt, CalType, TimeZone] = parseinputs(mfilename, t1, t2, dt, varargin{:});

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
   if CalType == "noleap"
      T = rmleapinds(T);
   end
end

%% Parse inputs
function [t1, t2, dt, CalType, TimeZone] = parseinputs(funcname, t1, t2, dt, varargin)

   p = inputParser;
   p.FunctionName = funcname;
   p.CaseSensitive = false;
   p.KeepUnmatched = true;

   validoption = @(x) ~isempty(validatestring(x, {'noleap', 'leap'}));

   p.addRequired('t1', @(x)isnumeric(x)|isdatetime(x));
   p.addRequired('t2', @(x)isnumeric(x)|isdatetime(x));
   p.addRequired('dt', @(x)ischar(x)|isduration(x)|iscalendarduration(x));
   p.addOptional('CalType', 'leap', validoption);
   p.addParameter('TimeZone', 'nan', @ischar); % 'UTC'
   p.parse(t1, t2, dt, varargin{:});

   t1 = p.Results.t1;
   t2 = p.Results.t2;
   dt = p.Results.dt;
   CalType = p.Results.CalType;
   TimeZone = p.Results.TimeZone;

   if ~isdatetime(t1)
      try
         t1 = todatetime(t1);
         t2 = todatetime(t2);
      catch ME
         % let it pass
      end
   end
end
