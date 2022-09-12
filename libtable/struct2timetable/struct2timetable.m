function T = struct2timetable(Struct,Time)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   p                 = inputParser;
   p.FunctionName    = 'struct2timetable';
   p.CaseSensitive   = false;
   p.KeepUnmatched   = true;
   
   validStruct       = @(x)validateattributes(x,{'struct'},             ...
                        {'nonempty'},                                   ...
                        'struct2timetable','Struct',1);
   validTime         = @(x)validateattributes(x,{'datetime'},           ...
                        {'nonempty'},                                   ...
                        'struct2timetable','Time',2);

   addRequired(   p,'Struct',                      validStruct          );
   addRequired(   p,'Time',                        validTime            );
   
   parse(p,Struct,Time);
   
   Struct   = p.Results.Struct;
   Time     = p.Results.Time;
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



   T  = struct2table(Struct);
   T  = table2timetable(T,'RowTimes',Time);