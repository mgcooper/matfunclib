function tf = isfig(varargin)
   %ISFIG Returns true for inputs that are figure handles.
   %
   %  tf = isfig(fig)
   %  tf = isfig(fig, ax)
   %  tf = isfig(fig1, fig2)
   %
   % This function identifies figure handles. In MATLAB versions prior to
   % R2014b, numeric values that coincide with figure numbers might be
   % erroneously identified as figure handles. Use caution in such cases.
   %
   % See also isaxis

   inoctave = exist ("OCTAVE_VERSION", "builtin") > 0;

   tf = false(size(varargin));
   for k = 1:nargin
      if inoctave
         tf(k) = isfigure(varargin{k});
      else
         if ~verLessThan('matlab', '8.4')
            tf(k) = isa(varargin{k}, 'matlab.ui.Figure');
         else
            tf(k) = isnumeric(varargin{k}) && isscalar(varargin{k}) && ...
               ishandle(varargin{k}) && strcmp(get(varargin{k}, 'Type'), 'figure');

            if tf(k)
               wid = ['custom:' mfilename ':ambiguousFigureHandle'];
               msg = ['Non-figure numeric scalars may be incorrectly ' ...
                  'identified as figure handles in pre-R2014b.'];
               warning(wid, msg);
            end
         end
      end
   end
end
