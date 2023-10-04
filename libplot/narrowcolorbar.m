function c = narrowcolorbar( delta,title,label )
   %NARROWCOLORBAR Add a narrow colorbar with width adjusted by delta percent
   %
   %
   % 
   % See also:

   c = colorbar;
   axpos = get(gca,'Position');
   cpos = get(c,'Position');
   cpos(3) = delta*cpos(3);
   set(c,'Position',cpos);
   set(gca,'Position',axpos);

   % new, add title
   if nargin==2
      set(get(c,'title'),'string',title)
   elseif nargin==3
      c.Label.String = label;
   end
end
