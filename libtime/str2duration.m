function dt = str2duration(dt,varargin)
p = MipInputParser;
p.FunctionName = 'str2duration';
p.addRequired('dt',@(x)ischar(x));
p.addParameter('caltime',false,@(x)islogical(x));
p.parseMagically('caller');

% decided to comment out the warning. if 'mm' or 'w' is requested, it
% should be obvious or will become obvious

switch dt
   case 'y'
      dt = years(1); if caltime == true; dt = calyears(1); end
   case 'mm'
      % no option for non-calendar month duration
      dt = calmonths(1);
      % if caltime == false; warning('dt is calendar duration'); end 
   case 'w'
      % no option for non-calendar week duration
      dt = calweeks(1); 
      % if caltime == false; warning('dt is calendar duration'); end 
   case 'd'
      dt = days(1); if caltime == true; dt = caldays(1); end
   case 'h'
      dt = hours(1);
   case 'm'
      dt = minutes(1);
   case 's'
      dt = seconds(1);
end