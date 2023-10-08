function m = ft2m(f)
   % Convert feet to meters
   if nargin < 1
      m = [];
   else
      m = f./3.28083989501;
   end
end
