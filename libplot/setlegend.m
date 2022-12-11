function leg = setlegend(txt,varargin)
%SETLEGEND default legend settings

% this won't work, it's just an example of where to start
% see changeLegLines and figformat

% thicken the lines
icons(3).LineWidth  = 2.5;
icons(5).LineWidth  = 2.5;

% shorten the lines
icons(3).XData      = 2/3*icons(3).XData;
icons(5).XData      = 2/3*icons(5).XData;

% move the text
lpos1               = icons(1).Position;
lpos2               = icons(2).Position;
icons(1).Position   = [2/3*lpos1(1) lpos1(2) 0];
icons(2).Position   = [2/3*lpos2(1) lpos2(2) 0];

% resize the box
hl.ItemTokenSize(1) = 10;

% move the box
hl.Position(2)  = 0.95*hl.Position(2);