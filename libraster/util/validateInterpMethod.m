function method = validateInterpMethod(method, interpfun)
   %VALIDATEINTERPMETHOD Validate an interpolation method for a given function.
   %
   %  method = validateInterpMethod(method) validates METHOD against the interp1
   %  method set (the most permissive of the built-in lists).
   %
   %  method = validateInterpMethod(method, INTERPFUN) validates METHOD against
   %  the methods supported by INTERPFUN -- a function NAME such as 'interp1',
   %  'interp2', 'interp3', 'interpn', 'griddedInterpolant', 'griddata',
   %  'scatteredInterpolant', 'mapinterp', or 'geointerp'. Different interpolation
   %  functions accept different methods (e.g. griddata adds 'natural'/'v4';
   %  interp2 drops 'pchip'/'next'/'previous'), so pass the one you will call.
   %
   %  method = validateInterpMethod(method, VALIDMETHODS) validates METHOD against
   %  an explicit cellstr / string-array VALIDMETHODS, used as-is.
   %
   % Example
   %   m = validateInterpMethod('natural', 'griddata');        % ok
   %   m = validateInterpMethod('pchip', 'interp2');           % errors (interp2)
   %   m = validateInterpMethod(m, {'nearest','linear'});      % explicit list
   %
   % See also: validatestring, interp1, interp2, griddata, scatteredInterpolant,
   %   mapinterp, geointerp

   if nargin < 2 || isempty(interpfun)
      validMethods = interpMethodSet('interp1');
   elseif iscell(interpfun) || (isstring(interpfun) && ~isscalar(interpfun))
      % An explicit list of valid methods (back-compatible with callers that
      % pass a cellstr, e.g. gridxyz).
      validMethods = cellstr(interpfun);
   elseif ischar(interpfun) || isstring(interpfun)
      % A single function name -> look up that function's valid method set.
      validMethods = interpMethodSet(interpfun);
   else
      error('matfunclib:validateInterpMethod:badArg', ...
         ['Second argument must be an interpolation function name or a list ' ...
         'of valid methods.'])
   end

   method = validatestring(method, validMethods);
end

function methods = interpMethodSet(interpfun)
   % Valid interpolation methods for each supported interpolation function.
   switch lower(char(interpfun))
      case {'interp1', 'griddedinterpolant'}
         methods = {'linear', 'nearest', 'next', 'previous', 'pchip', ...
            'cubic', 'v5cubic', 'makima', 'spline'};
      case {'interp2', 'interp3', 'interpn'}
         methods = {'linear', 'nearest', 'cubic', 'makima', 'spline'};
      case 'griddata'
         methods = {'linear', 'nearest', 'natural', 'cubic', 'v4'};
      case 'scatteredinterpolant'
         methods = {'linear', 'nearest', 'natural'};
      case {'mapinterp', 'geointerp'}
         methods = {'linear', 'nearest', 'cubic', 'spline'};
      otherwise
         error('matfunclib:validateInterpMethod:unknownFunction', ...
            'No interpolation method set is defined for "%s".', char(interpfun));
   end
end
