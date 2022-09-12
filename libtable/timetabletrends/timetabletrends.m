function [Trends,Tab] = timetabletrends(T,varargin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   p = MipInputParser;
   p.FunctionName = 'timetabletrends';
   p.PartialMatching = true;
   
   p.addRequired('T',                        @(x)istimetable(x));
   p.addParameter('Time',        NaT,        @(x)isdatetime(x));
   p.addParameter('timestep',    'unset',    @(x)ischar(x));
   p.addParameter('varnames',    'unset',    @(x)ischar(x)|iscell(x)|isstring(x));
   p.addParameter('method',      'ols',      @(x)ischar(x));
   p.addParameter('anomalies',   true,       @(x)islogical(x)           );
   p.addParameter('quantile',    NaN,        @(x)isnumeric(x)           );
   p.parseMagically('caller');
                              
   Time     = p.Results.Time;
   vars     = p.Results.varnames;
   method   = p.Results.method;
   timestep = p.Results.timestep;
   quantile = p.Results.quantile;
   
   if string(method)=="qtl" && isnan(quantile)
      error('must provide quantile for method ''qtl''')
   end
   
   % Make sure to check trenddecomp once I have R2021b or above
   % see JUST toolbox in mysource
   % see MTA toolbox in mysource
   % see ChangeDetection in mysource
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% NOTE: The timestep checking produces a regressor TimeX so the regression
% on time duration, not the actual time, so if the time is year, then the
% regression goes on 1:numyears rather than year1:1:yearFinal, which
% creates a problem if later you want to use the ab values to predict
% something on the original times. BUT, only the intercept should be
% affected, so I added the regressor to the table.
% UPDATE UPDATE: regressing on years might be best. For short-time data,
% force the user to regress on days, hours, minutes, or seconds, no months

% if not provided, use the Time variable in the table
   if isnat(Time) 
      T     = renametimetabletimevar(T); % make T time variable T.Time
      Time  = T.Time;
   end
   
% if not provided, get the variable names in the table (and units)
   if string(vars) == "unset"
      vars  = T.Properties.VariableNames;
      units = T.Properties.VariableUnits;
   end
   
   nt    = height(Time);
   nvars = numel(vars);

% find nan-indices
   %inan  = isnan(Data);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
% work in progress

   [timestep,TimeX] = settimestep(T,Time,timestep);
   
% FOR NOW, just use elapsedTime to make a regressor, that way the
% function returns the trends and timeseries with same units as input

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
   
   % Part 1 - compute the trends
   ab = nan(2,nvars);
   
   for n = 1:nvars
      thisvar  = vars{n};
      
      switch method
         case 'ols'
            ab(:,n)  = olsfit(TimeX,T.(thisvar));
         case 'ts'
            ab(:,n)  = tsregr(TimeX,T.(thisvar));
         case 'qtl'
            ab(:,n)  = quantreg(TimeX,T.(thisvar),qtl);
      end
   end
   
   % Convert to table
   Tab   = array2table(ab,'VariableNames',vars,'RowNames',{'a','b'});
   
   
   % Part 2 - evaluate the trend timeseries
   tstr     = nan(nt,nvars);
   tvars    = cell(1,nvars);
   for n = 1:nvars
   
      thisvar     = vars{n};
      thisab      = Tab.(thisvar);
      tstr(:,n)   = thisab(1) + thisab(2).*TimeX;
      tstr(:,n)   = setnan(tstr(:,n),isnan(T.(thisvar)));
      
      % to append 'trend' after each variable name, so Trends can be
      % synchronized with input table T, use this, otherwise if sending
      % back Trends without the original data, use the og varnames
      % tvars{n}    = [thisvar 'trend'];
      
      tvars{n}    = thisvar;

   end
   
   % Convert to timetable
   Trends   =  array2timetable(tstr,'VariableNames',tvars,'RowTimes',Time);
  
   % synchronize with the original table if they are the same size
   % holding off on this for now
   
   % add the ab values as a property
   Trends   =  addprop(Trends,   {  'TrendIntercept', 'TrendSlope'},    ...
                                 {  'variable',       'variable'  }     );
                            
   % update the properties
   Trends.Properties.CustomProperties.TrendIntercept    = ab(1,:);
   Trends.Properties.CustomProperties.TrendSlope        = ab(2,:);

   % add the regressor   
   Trends.TimeX   = TimeX;

   % update units, including TimeX. Trends has same units as the data
   units{end+1}   = timestep.Format;
   
   Trends.Properties.VariableUnits  = units;
   
   % now add /timestep to the ab (trend slope) units
   for n = 1:numel(units)-1
      units{n} = [units{n} '/' timestep.Format];
   end
   
   Tab.Properties.VariableUnits  = units(1:end-1);
   
   
  
end


function [timestep,TimeX] = settimestep(T,Time,timestep)
   
   % NOTE: need to reconcile this with timetabletimestep.m
   % NOTE: right now elapsedTime and dTime are not returned. elapsedTime
   % might be useful for computing the total change
   
   % get the time unit, duration, and timestep
   elapsedTime    =  max(Time) - min(Time);  % will be in hh:mm:ss
   dTime          =  diff(Time);             % timestep in hh:mm:ss
   
   % if no timestep was provided, check if there is a timestep property
   if string(timestep) == "unset" % isnan(timestep) || isnat(timestep)
      
      timestep = T.Properties.TimeStep; % note: this is a calendarDuration
      
   % because T.Properties.TimeStep returns a duration, I set timestep in
   % the if/switch below to durations, otherwise I would have 'years' in
   % place of years(1) in the next block, and after that, a switch that
   % sets the timestep in duration and the format, but I don't have a way
   % to convert T.Properties.TimeStep to 'years','days','minutes', etc.
      
   % if not, try to infer the timestep
      if isempty(timestep)
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
         
      % we got the timestep from the timetable, so it is probably a
      % calendar duration, and we need to do this
      else 
         
         if iscalendarduration(timestep)
            
            [y,m,d] = split(timestep,{'years','months','days'});
            
            if y == 1
               timestep    = years(1);
            elseif m == 1
               timestep    = months(1);
            elseif d == 1
               timestep    = days(1);
               
            % I think if the timestep is <1day, it won't be
            % calendarDuration, so I didn't add minutes/seconds
            elseif d*24 == 1        
               timestep    = hours(1);
            end
         end
      end
   else
         
      % if here, convert user-provided timestep to a duration
      switch timestep
         case 'y'
            timestep             =  years(1);
         case 'd'
            timestep             =  days(1);
         case 'h'
            timestep             =  hours(1);
         case 'm'
            timestep             =  minutes(1);
         case 'seconds'
            timestep             =  seconds(1);
      end
      
   end % timestep should be a duration if here
   
   % now set the format based on the timestep
   switch timestep
      case years(1)
         dTime.Format         =  'y';
         elapsedTime.Format   =  'y';
         TimeX                =  years([0; cumsum(dTime)]);
      case days(1)
         dTime.Format         =  'd';
         elapsedTime.Format   =  'd';
         TimeX                =  days([0; cumsum(dTime)]);
      case hours(1)
         dTime.Format         =  'h';
         elapsedTime.Format   =  'h';
         TimeX                =  hours([0; cumsum(dTime)]);
      case minutes(1)
         dTime.Format         =  'm';
         elapsedTime.Format   =  'm';
         TimeX                =  minutes([0; cumsum(dTime)]);
      case seconds(1)
         elapsedTime.Format   =  's';
         dTime.Format         =  's';
         TimeX                =  seconds([0; cumsum(dTime)]);
   end
   
%    % note, this works directly on dTime, w/o converting format
%    dTime    =  diff(Time);
%    Tdays    =  [0; days(cumsum(dTime))];
%    Tyears   =  [0; years(cumsum(dTime))];
   
end
   