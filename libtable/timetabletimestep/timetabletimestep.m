function timestep = timetabletimestep(T)

% NOTE: see solution in padtimetable to check if table is regular wrt
% calmonths

% make sure the T time dimension is named 'Time'
T     = renametimetabletimevar(T);
Time  = T.Time;

% if the timetable doesn't have a set timestep, this will be empty
% if it does have one, it will be a calendarDuration
timestep = T.Properties.TimeStep;

% get the time unit, duration, and timestep
dTime          =  diff(Time);             % timestep in hh:mm:ss
elapsedTime    =  max(Time) - min(Time);  % will be in hh:mm:ss
dElapsedTime   =  elapsedTime/height(T);  % just an idea, not used


% because T.Properties.TimeStep returns a duration, I set timestep in
% the if/switch below to durations, otherwise I would have 'years' in
% place of years(1) in the next block, and after that, a switch that
% sets the timestep in duration and the format, but I don't have a way
% to convert T.Properties.TimeStep to 'years','days','minutes', etc.

% if T doesn't have a timestep, try to infer the timestep
if isempty(timestep) || isnan(timestep) % || isnat(timestep) % isnat errors if timestep is a calendarduration
   
   if round(years(median(dTime))) == 1
      timestep    =  years(1);
   elseif round(days(median(dTime))) == 1
      timestep    =  days(1);
   elseif round(hours(median(dTime))) == 1
      timestep    =  hours(1);
   elseif round(minutes(median(dTime))) == 1
      timestep    =  minutes(1);
   elseif round(seconds(median(dTime))) == 1
      timestep    =  seconds(1);
   end
   
   % otherwise, use the timetable timestep, which is a calendar duration,
   % and we want to convert it to a regular duration
else
   
   if iscalendarduration(timestep)
      
      [y,m,d] = split(timestep,{'years','months','days'});
      
      % NOTE: matlab doesn't have a "months" duration, which is
      % reasonable since months have different durations, but they do
      % have a standard year, so I use years(1)/12 for months
      if y == 1
         timestep    = years(1);
      elseif m == 1
         timestep    = years(1)/12;
         monthflag   = true;
         
         % maybe issue a warning or maybe the easiest thing is to just
         % return the varaible with units /year
         warning('timestep is monthly, using standard year divided by 12, duration unit is years if called from trend functions');
         
         %          % this was suggested online, it would work for days or any
         %          % function that has a duration function i.e. not 'cal' so
         %          % 'days' not 'caldays' would work, but months only has calmonths
         %          [y,m,d,t]   = split(timestep, {'years','months','days','time'});
         %          duration    = calmonths(m) + t;
         
      elseif d == 1
         timestep    = days(1);
         
         % I think if the timestep is <1day, it won't be
         % calendarDuration, so I didn't add minutes/seconds
      elseif d*24 == 1
         timestep    = hours(1);
      end
   end
end

% now set the format based on the timestep
switch timestep
   case years(1)
      dTime.Format         =  'y';
      elapsedTime.Format   =  'y';
   case years(1)/12
      dTime.Format         =  'y'; % have to use years
      elapsedTime.Format   =  'y';
   case days(1)
      dTime.Format         =  'd';
      elapsedTime.Format   =  'd';
   case hours(1)
      dTime.Format         =  'h';
      elapsedTime.Format   =  'h';
   case minutes(1)
      dTime.Format         =  'm';
      elapsedTime.Format   =  'm';
   case seconds(1)
      elapsedTime.Format   =  's';
      dTime.Format         =  's';
end
