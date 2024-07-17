function tf = isaxis(varargin)
   %ISAXIS Return true for any inputs that are axes objects.
   %
   %  tf = isaxis(ax)
   %  tf = isaxis(fig, ax)
   %  tf = isaxis(ax1, ax2)
   %
   % This function checks if the provided input arguments are axes objects.
   % Compatible with Octave and MATLAB.
   %
   % See also: isfig

   inoctave = exist ("OCTAVE_VERSION", "builtin") > 0;

   tf = false(size(varargin));
   for k = 1:nargin
      if inoctave
         tf(k) = ishandle(varargin{k}) ...
            && strcmp(get(varargin{k}, 'type'), 'axes');
      else
         if ~verLessThan('matlab', '8.4')
            tf(k) = isa(varargin{k}, 'matlab.graphics.axis.AbstractAxes');

         else
            % Pre-R2014b: Handle numeric handles with caution.
            tf(k) = (isnumeric(varargin{k}) && isscalar(varargin{k}) ...
               && ishandle(varargin{k}) ...
               && strcmp(get(varargin{k}, 'Type'), 'axes'));
         end
      end
   end
end
