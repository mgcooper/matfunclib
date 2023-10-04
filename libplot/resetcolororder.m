function resetcolororder(varargin)
   %RESETCOLORORDER Reset the axes color order to the default first color.
   %
   %  resetcolororder() resets the current axis to color order index 1
   %
   %  resetcolororder(obj) resets the axes 'obj' to color order index 1
   %
   % See also: setcolors, ColorOrderIndex

   if nargin < 1
      ax = gca;
   end
   set(ax,'ColorOrderIndex',1)
end
