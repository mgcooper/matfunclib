function varargout = plotraster(Z, varargin)
   %PLOTRASTER Plot a raster (image).
   %
   % H = plotraster(Z)
   % H = plotraster(Z, R)
   % H = plotraster(Z, X, Y)
   % H = plotraster(ax, _)
   %
   % Notes
   %
   % See R2Grid for a diagram to understand why [1, R.RasterSize(2)]
   % captures the grid cell centers of the first and last X pixel and
   % similarly [1, R.RasterSize(1)] the first and last Y pixel.
   % TLDR: the pixel centers are from 1:numpixels, the cell edges are
   % from 0.5:numpixels-0.5.
   %
   % See also: rastershow, mapshow, geoshow, imagesc, imagscn

   % Verify the input count
   narginchk(1, Inf)

   % Parse possible axes input.
   [ax, args] = parsegraphics(varargin{:});

   % Get handle to either the requested or a new axis.
   if isempty(ax)
      ax = gca;
   end

   % Parse optional axis ratio
   [style, args, nargs] = parseoptarg(args, ...
      {'tight', 'padded', 'fill', 'equal', 'image', 'square', 'normal'}, 'image');

   % Parse the inputs. Compute the X and Y coordinates of the centers of the
   % first and last columns and first and last rows.
   if nargs == 0
      X = 1:size(Z, 2);
      Y = size(Z, 1):-1:1;
      XTicks = X;
      YTicks = Y;

   elseif nargs == 1
      R = args{1};
      rasterSize = R.RasterSize;

      if R.CoordinateSystemType == "planar"

         [X, Y] = R.intrinsicToWorld([1 rasterSize(2)], [1 rasterSize(1)]);
         dX = R.CellExtentInWorldX;
         dY = R.CellExtentInWorldY;

         % Create full grids:
         % [Xgrid, Ygrid] = R.worldGrid;
      else

         [Y, X] = R.intrinsicToGeographic([1 rasterSize(2)], [1 rasterSize(1)]);
         dX = R.CellExtentInLongitude;
         dY = R.CellExtentInLatitude;

         % Create full grids:
         % [Ygrid, Xgrid] = R.geographicGrid;

         % Another way to create X Y limits:
         % X = R.intrinsicXToLongitude([1 rasterSize(2)]);
         % Y = R.intrinsicYToLatitude( [1 rasterSize(1)]);

      end

      XTicks = sort(min(X(:)):dX:max(X(:)), 'ascend');
      YTicks = sort(min(Y(:)):dY:max(Y(:)), 'descend');

      % Creating full grids:
      % X2 = [min(Xgrid(:)), max(Xgrid(:))];
      % Y2 = [max(Ygrid(:)), min(Ygrid(:))];
      % Compare X2 to X and Y2 to Y.

   elseif nargs == 2

      % [X, Y] = prepareMapGrid(X, Y);
      [XTicks, YTicks] = gridvec(args{1}, args{2});
      X = [min(XTicks(:)) max(XTicks(:))];
      Y = [max(YTicks(:)) min(YTicks(:))];

      %Y = [min(Y(:)) max(Y(:))];
   end

   % prep ticks
   numticks = min(numel(XTicks), 10);
   XTicks = sort(XTicks(1:round(numel(XTicks)/numticks):end));
   YTicks = sort(YTicks(1:round(numel(YTicks)/numticks):end));

   % X and Y are two-element vectors representing the coordinates of the first
   % and last pixel centers. X(1), Y(1) = upper left , X(2), Y(2) = lower right.
   H = image(Z, 'XData', X, 'YData', Y, 'CDataMapping', 'scaled', 'Parent', ax);

   % From the "image" doc for 'XData':
   % two-element vector — Use the first element as the location for the center
   % of C(1,1) and the second element as the location for the center of C(m,n),
   % where [m,n] = size(C).
   % So if the x data is from -180-180, it should be the same as 0-360.

   % Display transparent nan's. This will work if Z is 3-d (e.g. RGB).
   set(H, 'AlphaData', ~isnan(H.CData))

   % For reference, this works too, but X, Y might need to be the coordinates:
   % H = imagesc(X, Y, Z); set(gca,'YDir','normal');

   % Override the automatic reversal of YDir by image.
   set(ax, 'Ydir', 'Normal', ...
      'XTick', XTicks, 'YTick', YTicks, 'TickLength', [0 0]);
   grid off
   axis(ax, style)

   if nargout == 1
      varargout{1} = H;
   end
end

% % Check that X,Y are defined correctly
% scatter(X(1,1), Y(1,1), 'filled')
% scatter(X(1,2), Y(1,2), 'filled')

% % This deosn't work b/c for pcolor, we would need to extend the grid outward
% by 1/2 pixel
% [X, Y] = prepareMapGrid(X, Y);
% figure; pcolor(X,Y,Z);

% % Set properties if necessary
% if ~isempty(props)
%   set(H,props{:,1},props{:,2});
% end
%
% % Set labels if necessary
% if ~isempty(xlbl)
%   xlabel(xlbl);
% end
% if ~isempty(ylbl)
%   ylabel(ylbl);
% end
%
% % Return the handle
% if nargout == 1
%   H = H;
% end
