function p = patchlegendlines(legobj, PatchProps, LineProps)
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
   % To set individual props per patch line, use LineProps.<LineProp> e.g.
   % one color per line can be set in the loop step set(p(n), ...), but for each
   % of these props, need to add them to arguments and add the check that there
   % is either one per patch, or repmat the one value.

   % Line-related patch properties include:
   % - LineColor
   % - LineJoin
   % - LineMarker
   % - LineStyle
   % - LineWidth
   %
   % If LineProps includes any of these properties and the user supplies value
   % for them, they will not appear in PatchProps. Thus, afaik, it is impossible
   % to set identical Patch and Line properties, so they can either be set
   % identically for both, or enforce no change to these patch props and use
   % them to control the line. The former seems better since the point is to
   % enable plotting lines on top of patches, and the patch will appear in the
   % legend as it does on the figure except for some properties like FaceAlpha
   % which can be set here without interfering with the line properties.

   % FaceVertexCData controls the edge color, but the line is actually an edge
   %
   % When linestyle is '-', white replaces the entire edge
   % When linestyle is '--', the edge is traced by a white -- line thus
   % alternating white dashes and whatever color the patch is.
   % I thought if maybe an extra trace around in the opposite direction was
   % performed with FaceVertexCData = [1 1 1] it might eliminate all the colored
   % portions by overwriting them but doesn't seem to work.
   %
   % Might be preferable to force linewidth=1, the alternating white dashes are
   % almost imperceptible.
   %
   % NOTE: one thing I did not test is the XData and YData properties, after
   % the Vertices property is updated, those properties are not updated
   % automatically.

   arguments
      % legobj = getlegobj(gcf)
      legobj = getlegend(gcf)
      PatchProps.?matlab.graphics.primitive.Patch

      % Default values made to match the number of patches in parseLineProps
      LineProps.LineColor = get(gca, 'ColorOrder')
      LineProps.LineMarker (1, :) string = "none"
      LineProps.LineStyle (1, :) string = "-"
      LineProps.LineWidth (1, :) {mustBeNumeric} = 1
   end
   PatchProps = namedargs2cell(PatchProps);
   LineProps.LineMarker = cellstr(LineProps.LineMarker);
   LineProps.LineStyle = cellstr(LineProps.LineStyle);

   if isempty(legobj)
      error( ...
         'This function requires legend creation syntax [handle, obj] = legend(_)')
   end

   % Main function
   p = findall(legobj, 'Type', 'Patch');

   [Colors, LineProps] = parseLineProps(LineProps, numel(p));

   for n = 1:numel(p)

      % Previously these were set, now they must be provided, except linestyle
      % p(n).FaceAlpha = 0.25;
      % p(n).LineWidth = 2;

      if strcmp(p(n).LineStyle, 'none') == true
         % set(p(n), PatchProps{:}, 'Marker', CustomOpts.LineMarker{n}, 'LineStyle', '-');
         set(p(n), 'LineStyle', LineProps.LineStyle{n}, PatchProps{:}); % Jan 2024
      else
         % set(p(n), PatchProps{:}, 'Marker', CustomOpts.LineMarker{n});
         set(p(n), PatchProps{:});
      end

      % The new vertices can also be constructed like this:
      % v = [ p(n).Vertices;
      %       p(n).Vertices(1, 1),    mean(p(n).Vertices(:, 2));
      %       p(n).Vertices(end, 1),  mean(p(n).Vertices(:, 2))
      %       ]

      x = get(p(n), 'xdata');
      y = get(p(n), 'ydata');

      x = [x; x(1); x(end)]; %#ok<*AGROW>
      y = [y; mean(y); mean(y)];
      c = [ repmat([1, 1, 1], [4 1]); repmat(Colors(n, :), [2 1]) ];
      ff = [1 2 3 4; 5 6 nan nan];

      % % TEST - trace around the edge one more time
      % x = [x; x(1); x(end); flip(x)]; %#ok<*AGROW>
      % y = [y; mean(y); mean(y); flip(y)];
      % c = [ repmat([1, 1, 1], [4 1]);
      %    repmat(Colors(n, :), [2 1])
      %    repmat([1, 1, 1], [4 1])
      %    ];
      % ff = [1 2 3 4; 5 6 nan nan; 1 2 3 4];
      % % ff = [1 2 3 4; 5 6 nan nan; 4 3 2 1];
      % % TEST

      set(p(n), 'vertices', [x y], ...
         'faces', ff, ...
         'faceVertexCData', c, ...
         'edgecolor', 'flat', ...
         'LineStyle', LineProps.LineStyle{n}, ...
         'LineWidth', LineProps.LineWidth(n))

      % plot another patch with edge color but no face color?
   end

   % Before and after:
   % p(n).FaceVertexCData = [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0]
   % p(n).FaceVertexCDataMode = 'auto' -> 'manual
   % p(n).FaceVertexAlphaData = [1; 1; 1; 1] -> [1; 1; 1; 1]
   % p(n).AlphaDataMapping = 'scaled' -> 'scaled'
   % p(n).CDataMapping = 'scaled' -> 'scaled'
   % p(n).CDataMode = 'auto' -> 'manual'
   % p(n).EdgeAlpha = 1 -> 1
   % p(n).EdgeColor = 'none' -> 'flat'
   % p(n).FaceAlpha = 0.25
   % p(n).FaceColor = [0.6207    0.3103    0.2759]
   % p(n).Faces = [1 2 3 4]
   % p(n).LineStyle = '-'
   % p(n).LineWidth = 1
   % p(n).Vertices = [  0.0223    0.1329
   %                    0.0223    0.2145
   %                    0.1894    0.2145
   %                    0.1894    0.1329]

   % Old input parsing
   % if nargin < 1
   %    legobj = getlegobj(gcf);
   %    if isempty(legobj)
   %       error( ...
   %          'This function requires legend creation syntax [handle, obj] = legend(_)')
   %    end
   % end
end

function [colors, LineProps] = parseLineProps(LineProps, N)

   % If a figure has multiple lines and patches, it's hard or impossible to know
   % which index in c corresponds to the line plotted on the patch. So the user
   % needs to supply the correct number of custom colors or none and the default
   % colororder is used. BUT NOTE: the commented out method may work:
   %  c = get(p(n), 'faceVertexCData');

   if N <= size(LineProps.LineColor, 1)
      % The user supplied one color per patchline or there are fewer patches
      % than default colors.
      colors = LineProps.LineColor(1:N, :);
   elseif size(LineProps.LineColor, 1) == 1
      % The user supplied one color for all patchlines
      colors = repmat(LineProps.LineColor, N, 1);
   else
      % More patches than defaultcolors, or fewer colors supplied than patches
      error('supply one custom LineColor per patch line')
   end

   PropList = {'LineMarker', 'LineStyle', 'LineWidth'};

   for prop = PropList
      switch numel(LineProps.(prop{:}))
         case N
            % no action needed
         case 1
            LineProps.(prop{:}) = repmat(LineProps.(prop{:}), N, 1);
         otherwise
            error(['supply one custom ' (prop{:}) 'per patch line'])
      end
   end
end
