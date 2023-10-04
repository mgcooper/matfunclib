function [x, y] = textcoords(xpct, ypct)
   %TEXTCOORDS Get plot coordinates relative to lower left corner to place text
   %
   %   [x, y] = textcoords(xpct, ypct)
   %
   % See also: textbox

   xlims = get(gca, 'xlim');
   ylims = get(gca, 'ylim');

   xrange = xlims(:, 2) - xlims(:, 1);
   yrange = ylims(:, 2) - ylims(:, 1);

   xoffset = xpct/100 .* xrange;
   yoffset = ypct/100 .* yrange;

   x = xlims(:, 1) + xoffset;
   y = ylims(:, 1) + yoffset;
end
