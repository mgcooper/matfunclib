function p = patchlegendlines(legobj, PatchProps)
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

   arguments
      legobj = getlegobj(gcf)
      PatchProps.?matlab.graphics.primitive.Patch
   end
   PatchProps = namedargs2cell(PatchProps);

   if isempty(legobj)
      error( ...
         'This function requires legend creation syntax [handle, obj] = legend(_)')
   end

   % Main function
   p = findall(legobj, 'Type', 'Patch');
   c = get(gca, 'ColorOrder');

   for n = 1:numel(p)

      % Previously these were set, now they must be provided, except linestyle
      % p(n).FaceAlpha = 0.25;
      % p(n).LineWidth = 2;

      set(p(n), PatchProps{:}, 'LineStyle', '-'); % Jan 2024

      x = get(p(n), 'xdata');
      y = get(p(n), 'ydata');
      x = [x; x(1); x(end)]; %#ok<*AGROW>
      y = [y; mean(y); mean(y)];
      % cc = get(h1(n), 'faceVertexCData');
      cc = [ repmat([1, 1, 1], [4 1]); repmat(c(n, :), [2,1]) ];
      ff = [1 2 3 4; 5 6 6 6];
      set(p(n), 'vertices', [x y], ...
         'faces', ff, ...
         'faceVertexCData', cc, ...
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
