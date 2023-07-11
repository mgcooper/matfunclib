function [x, y] = textcoords( xpct,ypct)
%TEXTCOORDS get plot coordinates relative to lower left corner to place text
% 
%   [x, y] = textcoords(xpct, ypct)
% 
% See also

xlims = get(gca,'xlim');
ylims = get(gca,'ylim');

xdif = xlims(:,2) - xlims(:,1);

xoffset = xpct/100 .* xdif;

x = xlims(:,1) + xoffset;

ydif = ylims(:,2) - ylims(:,1);

yoffset = ypct/100 .* ydif;

y = ylims(:,1) + yoffset;

end

