function varargout = setPieChartText(H, TextOpts)
   %SETPIECHARTTEXT
   %
   %  setPieChartText(H) set text properties of the pie chart with handle H.
   %
   % See also: setPieChartPatch
   arguments
      H matlab.graphics.primitive.Data
      TextOpts.?matlab.graphics.primitive.Text
   end
   % opts = namedargs2cell(TextOpts);
   
   % h = pie(1);
   % htext = h(2);
   % mc = metaclass(htext);
   % proplist = mc.PropertyList;

   htext = findobj(H, 'Type', 'Text');
   % Ntext = length(htext);

   % Apply the property-value pairs
   cellfun(@(prop, val) set(htext, prop, val), ...
      fieldnames(TextOpts), struct2cell(TextOpts))

   % Return the handle if requested
   if nargout > 0
      varargout{1} = H; 
   end
end