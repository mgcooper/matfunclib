function ttbl = trimtimetable(ttbl, t1, t2)
   %TRIMTIMETABLE trim timetable to dates that span t1,t2 inclusive
   %
   %
   % See also

   % parse inputs
   [ttbl, t1, t2] = parseinputs(ttbl, t1, t2, mfilename);

   % trim the time table
   ok = isbetween(ttbl.Time,t1,t2);
   ttbl = ttbl(ok,:);
end

function [T, t1, t2] = parseinputs(T, t1, t2, funcname)
   parser = inputParser;
   parser.FunctionName = funcname;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;

   validx = @(x)validateattributes(x,{'timetable'},{'nonempty'}, ...
      'trimtimetable','T',1);
   validy = @(x)validateattributes(x,{'datetime'},{'nonempty'}, ...
      'trimtimetable','t1',2);
   validz = @(x)validateattributes(x,{'datetime'},{'nonempty'}, ...
      'trimtimetable','t2',3);

   addRequired( parser,'T',  validx );
   addRequired( parser,'t1', validy );
   addRequired( parser,'t2', validz );

   parse(parser,T,t1,t2);

   T = parser.Results.T;
   t1 = parser.Results.t1;
   t2 = parser.Results.t2;
end
