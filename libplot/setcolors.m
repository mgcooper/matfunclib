function setcolors(p, colors)
   %SETCOLORS Set the Color property in each element of graphics handle array.
   %   
   %  setcolors(p, colors)
   % 
   % Inputs: 
   % p - nx1 plot handle object
   % colors - nx3 color triplet array
   % 
   % See also: setcolorbar

   for n = 1:length(p)
      p(n).Color = colors(n,:);
   end
end
