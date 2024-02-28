function p = patchlegendlines(legobj, PatchProps, CustomOpts)
   %PATCHLEGENDLINES Add lines to patch objects in legend using pre-2014 legobj
   %
   % The legobj must be created by call to legend:
   %
   % [leghandle,legobj] = legend(__)
   %
   % p = patchlegendlines(legobj)
   %
   % See also:

   % Changes
   % Jan 2024 - if a patch was plotted with no line and then a line was plotted
   % on top, the LineStyle property of the patch may be 'none'. In this case,
   % setting it to '-' will not affect the plotted patch but it will allow the
   % line to appear in the legend patch.

   % NOTE: PatchProps inherits all patch properties and all apply to each patch.
   % To set individual props per patch or line, use CustomOpts.<LineProp> e.g.
   % one color per line can be set in the loop step set(p(n), ...), but for each
   % of these props, need to add them to arguments and add the check that there
   % is either one per patch, or repmat the one value.

   arguments
      % legobj = getlegobj(gcf)
      legobj = getlegend(gcf)
      PatchProps.?matlab.graphics.primitive.Patch
      CustomOpts.LineStyle = '-'
      CustomOpts.LineColor = get(gca, 'ColorOrder')
      CustomOpts.LineMarker = repmat({'none'}, size(get(gca, 'ColorOrder'), 1), 1)
   end
   PatchProps = namedargs2cell(PatchProps);

   if isempty(legobj)
      error( ...
         'This function requires legend creation syntax [handle, obj] = legend(_)')
   end

   % Main function
   p = findall(legobj, 'Type', 'Patch');

   [colors, linestyles] = parseLineProps(CustomOpts, numel(p));

   for n = 1:numel(p)

      % Previously these were set, now they must be provided, except linestyle
      % p(n).FaceAlpha = 0.25;
      % p(n).LineWidth = 2;

      if strcmp(p(n).LineStyle, 'none') == true
         % set(p(n), PatchProps{:}, 'Marker', CustomOpts.LineMarker{n}, 'LineStyle', '-');
         set(p(n), 'LineStyle', CustomOpts.LineStyle{n}, PatchProps{:}); % Jan 2024
      else
         % set(p(n), PatchProps{:}, 'Marker', CustomOpts.LineMarker{n});
         set(p(n), PatchProps{:});
      end

      x = get(p(n), 'xdata');
      y = get(p(n), 'ydata');
      x = [x; x(1); x(end)]; %#ok<*AGROW>
      y = [y; mean(y); mean(y)];
      % c = get(p(n), 'faceVertexCData');
      c = [ repmat([1, 1, 1], [4 1]); repmat(colors(n, :), [2,1]) ];
      ff = [1 2 3 4; 5 6 6 6];
      set(p(n), 'vertices', [x y], ...
         'faces', ff, ...
         'faceVertexCData', c, ...
         'edgecolor', 'flat')
   end

   % Old input parsing
   % if nargin < 1
   %    legobj = getlegobj(gcf);
   %    if isempty(legobj)
   %       error( ...
   %          'This function requires legend creation syntax [handle, obj] = legend(_)')
   %    end
   % end
end

function [colors, linestyles] = parseLineProps(CustomOpts, N)
   
   % If a figure has multiple lines and patches, it's hard or impossible to know
   % which index in c corresponds to the line plotted on the patch. So the user
   % needs to supply the correct number of custom colors or none and the default
   % colororder is used. BUT NOTE: the commented out method may work: 
   %  c = get(p(n), 'faceVertexCData'); 
   
   if N <= size(CustomOpts.LineColor, 1)
      % The user supplied one color per patchline or there are fewer patches
      % than default colors.
      colors = CustomOpts.LineColor(1:N, :);
   elseif size(CustomOpts.LineColor, 1) == 1
      % The user supplied one color for all patchlines
      colors = repmat(CustomOpts.LineColor, N, 1);
   else
      % More patches than defaultcolors, or fewer colors supplied than patches
      error('supply one custom LineColor per patch line')
   end

   switch numel(CustomOpts.LineStyle)
      case N
         linestyles = CustomOpts.LineStyle;
      case 1
         linestyles = repmat(CustomOpts.LineStyle, N, 1);
      otherwise
         error('supply one custom LineStyle per patch line')
   end
end
