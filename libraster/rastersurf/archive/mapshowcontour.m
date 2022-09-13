function [ h ] = mapshowcontour( z,r )
%mapshowsurface alias for mapshow when "DisplayType" is "contour"
%   Detailed explanation goes here

h = mapshow(z,r,'DisplayType','contour');

axis tight

c = colorbar;
axpos = get(gca,'Position');
cpos = get(c,'Position');
cpos(3) = 0.5*cpos(3);
set(c,'Position',cpos);
set(gca,'Position',axpos);


end

