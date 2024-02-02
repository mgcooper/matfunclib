function varargout = setPieChartPatch(H, PatchOpts, CustomOpts)
   %SETPIECHARTPATCH
   %
   %  setPieChartPatch(H) set patch properties of the pie chart with handle H.
   %
   % See also: setPieChartText
   arguments
      H matlab.graphics.primitive.Data
      PatchOpts.?matlab.graphics.primitive.Patch
      CustomOpts.ColorPalette = colororder
      CustomOpts.KeepColors = false;
   end
   opts = namedargs2cell(PatchOpts);

   % If H is an array, 
   
   hpatch = findobj(H, 'Type', 'Patch');
   Npatch = length(hpatch);
   colors = CustomOpts.ColorPalette;
   Ncolor = size(colors, 1);

   % Create an index from 1:Nobjects
   idx = repmat(1:Ncolor, 1, ceil(Npatch/Ncolor));
   idx = idx(1:Npatch);

   % Set the pie slice colors
   if ~CustomOpts.KeepColors
      for n=1:Npatch
         hpatch(n).FaceColor = colors(idx(n),:);
      end
   end

   % Apply the property-value pairs
   cellfun(@(prop, val) set(hpatch, prop, val), ...
      fieldnames(PatchOpts), struct2cell(PatchOpts))

   % Return the handle if requested
   if nargout > 0
      varargout{1} = H; 
   end
end
