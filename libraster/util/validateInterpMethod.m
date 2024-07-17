function method = validateInterpMethod(method, validMethods)
   
   if nargin < 1
      validMethods = {'linear','makima','nearest','next','previous',...
         'pchip','cubic','v5cubic','spline'};
   end
   
   method = validatestring(method, validMethods);
end
