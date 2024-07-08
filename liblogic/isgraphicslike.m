function tf = isgraphicslike(varargin)
   %ISGRAPHICSLIKE return true for any inputs that might be a graphics object
   %
   %
   % See also: isfig isaxis isimage

   inoctave = exist ("OCTAVE_VERSION", "builtin") > 0;

   for k = nargin:-1:1
      arg = varargin{k};
      if inoctave
         warning('This function currently does not support Octave')
         % need to determine the appropriate method for octave
      else
         tf(k) = (isnumeric(arg) && isscalar(arg) && isgraphics(arg)) ...
            || isa(arg, 'matlab.graphics.Graphics');
      end
   end
end
