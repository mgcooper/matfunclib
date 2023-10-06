function tf = isaxis(varargin)
   %ISAXIS return true for any inputs that are axes objects
   %
   %
   % See also: isfig

   inoctave = exist ("OCTAVE_VERSION", "builtin") > 0;

   tf = false(size(varargin));  % preallocate result
   for k = 1:nargin
      if inoctave
         tf(k) = ishandle(varargin{k}) && strcmp(get(varargin{k}, 'type'), 'axes');
      else
         tf(k) = isa(varargin{k}, 'matlab.graphics.axis.AbstractAxes') || ...
            (isnumeric(varargin{k}) && isscalar(varargin{k}) && ...
            isgraphics(varargin{k}, 'axes'));
      end
   end
end
