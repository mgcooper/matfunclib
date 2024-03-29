function tf = isfig(varargin)
   %ISFIG Return true for any inputs that are figures
   %
   % tf = isfig(fig)
   % tf = isfig(fig, ax)
   % tf = isfig(fig1, fig2)
   %
   % See also isaxis


   % Check if any values in varargin are figures
   inoctave = exist ("OCTAVE_VERSION", "builtin") > 0;
   tf = false(size(varargin));  % preallocate result
   for k = 1:nargin
      if inoctave
         tf(k) = isfigure(varargin{k});
      else
         tf(k) = isa(varargin{k}, 'matlab.ui.Figure') || ...
            (isnumeric(varargin{k}) && isscalar(varargin{k}) && ...
            isgraphics(varargin{k}, 'figure'));
      end
   end
end
