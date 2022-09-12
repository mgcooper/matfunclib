function numtime = timetableduration(T,timeunit)

   % this needs some work ... calculations on datetimes will return true
   % values so stuff like leap years already being removed will yield
   % incorrect results (technically correct but I want incorrect ...)
   
   % although I could do:
   % numtime = years(data.Time(end)-data.Time(1))
   % that would return the exact value, and I am not sure which is
   % prefereable
   
   switch timeunit
      case 'years'
         numtime  = year(T.Time(end)) - year(T.Time(1)) + 1;
      case 'days'
         numtime = days(data.Time(end)-data.Time(1));
   end
         
         