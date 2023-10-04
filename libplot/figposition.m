function fpos = figposition(f)
   %FIGPOSITION Get figure position
   %
   %  fpos = figposition()
   %  fpos = figposition(fig)
   %
   % See also:

   if nargin==0
      fpos = get(gcf, 'Position');
   else
      fpos = get(f, 'Position');
   end
end
