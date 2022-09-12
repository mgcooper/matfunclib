function c = mycolorbar( width,height,location,title,label )
%NARROWCOLORBAR adds a colorbar. adjusts width by delta percent
%   Detailed explanation goes herec = colorbar;

narginchk(3,5)

if nargin<4
    title = '';
    label = '';
elseif nargin==4
    label = '';
end

switch location
    case {'southout','southoutside'}
        location = 'southoutside';
    case {'northout','northoutside'}
        location = 'northoutside';
    case {'eastout','eastoutside'}
        location = 'eastoutside';
    case {'westout','westoutside'}
        location = 'westoutside';
end

% this would be simpler but I could not get it to work
% if contains(location,'out')
%     location = replace(location,'out','outside');
% end

ax      = gca;
c       = colorbar('Location',location); pause(.01)
axpos   = ax.Position;
cpos    = get(c,'Position');
switch location
    case {'east','west','eastoutside','westoutside'}
%         cpos(2) = cpos(2)-(1-height)*cpos(2); % doesn't work for subplots
        cpos(3) = width*cpos(3);
        cpos(4) = height*cpos(4);
    case {'north','south','northoutside','southoutside'}
        cpos(1) = cpos(1)+(1-width)*cpos(1);
        cpos(3) = width*cpos(3);
        cpos(4) = height*cpos(4);
end
set(c,'Position',cpos);
set(gca,'Position',axpos);

% new, add title
ct          = get(c,'title');
ct.String   = title;
ct.Units    = 'normalized';

% not sure about this ... might not be worth the trouble
switch location
    case {'east','west','eastoutside','westoutside'}

    case {'north','south','northoutside','southoutside'}
        ct.Position(1) = 1.05;
        ct.Position(2) = c.Position(2);
end

c.Label.String = label;

end

