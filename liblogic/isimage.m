function tf = isimage(varargin)
   %ISIMAGE return true for any inputs that are image objects
   %
   %
   % See also: isfig isaxis

   inoctave = exist ("OCTAVE_VERSION", "builtin") > 0;

   tf = false(size(varargin));  % preallocate result
   for k = 1:nargin
      if inoctave
         warning('This function currently does not support Octave images')
         % need to check this in octave
         % tf(k) = ishandle(varargin{k}) && strcmp(get(varargin{k}, 'type'), 'image');
      else
         tf(k) = isa(varargin{k}, 'matlab.graphics.primitive.Image');
      end
   end
end
