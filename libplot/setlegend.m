function varargout = setlegend(L, LegendOpts, CustomOpts)
   %SETLEGEND default legend settings
   %
   % L = setlegend("Prop", "Val") sets the property-value pair for the legend
   % object of the active figure (gcf).
   %
   % L = setlegend(L, "Prop", "Val") sets the property-value pair for the legend
   % object L
   %
   % L = setlegend(H, "Prop", "Val") sets the property-value pair for the legend
   % object of the figure handle H
   %
   % See also: getlegend, setcolorbar, getcolorbar

   arguments
      L (:,1) = getlegend
      LegendOpts.?matlab.graphics.illustration.Legend
      CustomOpts.SetLegendLines (1,1) logical = false
   end

   % apply the property-value pairs
   cellfun(@(prop, val) set(L, prop, val), ...
      fieldnames(LegendOpts), struct2cell(LegendOpts))

   % send back the legend object if requested
   [varargout{1:nargout}] = dealout(L);

   % args = namedargs2cell(opts);
   % arrayfun(@(prop, val) set(L, prop, val), args(1:2:end-1), args(2:2:end))

   if CustomOpts.SetLegendLines == true

      return

      % this only an example of where to start
      % see changeLegLines and figformat

      % thicken the lines
      icons(3).LineWidth = 2.5;
      icons(5).LineWidth = 2.5;

      % shorten the lines
      icons(3).XData = 2/3*icons(3).XData;
      icons(5).XData = 2/3*icons(5).XData;

      % move the text
      lpos1 = icons(1).Position;
      lpos2 = icons(2).Position;
      icons(1).Position = [2/3*lpos1(1) lpos1(2) 0];
      icons(2).Position = [2/3*lpos2(1) lpos2(2) 0];

      % resize the box
      hl.ItemTokenSize(1) = 10;

      % move the box
      hl.Position(2) = 0.95*hl.Position(2);
   end
end
