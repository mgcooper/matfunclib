function [ h ] = mapsurf( z,r )
%mapshowsurface alias for mapshow when "DisplayType" is "surface"
%   Detailed explanation goes here

h = mapshow(z,r,'DisplayType','surface');

axis tight

c = colorbar;
axpos = get(gca,'Position');
cpos = get(c,'Position');
cpos(3) = 0.5*cpos(3);
set(c,'Position',cpos);
set(gca,'Position',axpos);

end

