function [rgb] = wacmap(film)
   %WACMAP Wes Anderson color palettes for MATLAB
   %
   %  [rgb] = wacmap(film)
   %   
   % Via https://wesandersonpalettes.tumblr.com/
   % 
   % See also:

   load(localfile(mfilename,'wacmaps'),'wacmaps')
   idx = strcmp(film, {wacmaps.Film});
   rgb = hex2rgb(wacmaps(idx).Hex);
end
