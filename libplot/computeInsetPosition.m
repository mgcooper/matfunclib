function position = computeInsetPosition(ax, location)

   % this was from plotRunoffRatio but there I knew the ratio e.g. width / 3,
   % height / 2, so need to either make those inputs, or use the flushlegend
   % approach which gets the size of the current legend (here axes)

   location = parseGraphicsLocation(location);

   axpos = ax.Position;
   width = axpos(3) / 3;
   height = axpos(4) / 2;
   corner = [(axpos(1) + axpos(3)) - width, (axpos(2) + axpos(4)) - height];
   position = [corner, width, height]; % [0.215 0.713 0.08 0.19]

end
