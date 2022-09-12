function c = narrowcolorbar( delta,title,label )
%NARROWCOLORBAR adds a colorbar. adjusts width by delta percent
%   Detailed explanation goes herec = colorbar;
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

