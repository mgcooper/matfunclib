function [rgb] = wacmap(film)
%Wes Anderson color palettes for MATLAB
%   Via https://wesandersonpalettes.tumblr.com/

load(localfile(mfilename,'wacmaps'),'wacmaps')

idx = strcmp(film, {wacmaps.Film});

rgb = hex2rgb(wacmaps(idx).Hex);

end
