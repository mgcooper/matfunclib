function calendar = annualCalendar(years,varargin)
   %ANNUALCALENDAR Create a datetime calendar for one or more years
   %
   %  calendar = annualCalendar(years)
   %  calendar = annualCalendar(years, timestep=timestep)
   %
   % Description
   %  calendar = annualCalendar(years) creates a datetime calendar for one or
   %  more years.
   %  calendar = annualCalendar(years, timestep=timestep) uses the specified
   %  timestep.
   %
   % See also

   parser = inputParser();
   parser.FunctionName=mfilename;
   parser.addRequired('years', @(x) isnumeric(x) | isdatetime(years));
   parser.addParameter('timestep', calyears(1), @(x) isduration(x) | ischar(x));
   parser.parse(years, varargin{:});
   timestep = parser.Results.timestep;

   % I never finished this, need to figure out how to determine if the
   % timestep is a year

   if isduration(timestep) % assume it's the timestep

      timestep  = hours(timestep);

      if timestep==24

         t1  = datetime(years,1,1);
         t2  = datetime(years,12,31);
         timestep  = caldays(1);

      else

         t1  = datetime(years,1,1,0,0,0);
         t2  = datetime(years,12,31,24-timestep,0,0);

         timestep  = hours(timestep);
      end

   else


      switch timestep

         case {'daily','day'}

            t1  = datetime(years,1,1);
            t2  = datetime(years,12,31);
            timestep  = caldays(1);

         case {'hourly','hour'}
            t1  = datetime(years,1,1,0,0,0);
            t2  = datetime(years,12,31,23,0,0);
            timestep  = hours(1);

      end

   end

   calendar = t1:timestep:t2;
   calendar = calendar(:);
end
