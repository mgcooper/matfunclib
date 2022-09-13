function [ h ] = mapshowmesh( z,r )
%mapshowsurface alias for mapshow when "DisplayType" is "mesh"
%   Detailed explanation goes here

h = mapshow(z,r,'DisplayType','mesh');

axis tight

c = colorbar;
axpos = get(gca,'Position');
cpos = get(c,'Position');
cpos(3) = 0.5*cpos(3);
set(c,'Position',cpos);
set(gca,'Position',axpos);

end

