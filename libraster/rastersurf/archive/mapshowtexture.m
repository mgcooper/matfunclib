function [ h ] = mapshowtexture( z,r )
%mapshowsurface alias for mapshow when "DisplayType" is "texturemap"
%   Detailed explanation goes here

h = mapshow(z,r,'DisplayType','texturemap');

axis tight

c = colorbar;
axpos = get(gca,'Position');
cpos = get(c,'Position');
cpos(3) = 0.5*cpos(3);
set(c,'Position',cpos);
set(gca,'Position',axpos);

end

