function varargout = plotraster(Z, varargin)

% Verify the input count
narginchk(2, Inf)

% Parse possible axes input.
[ax, args, nargs] = axescheck(varargin{:}); %#ok<ASGLU>

% Get handle to either the requested or a new axis.
if isempty(ax)
   ax = gca;
end
    
% Parse the inputs. Compute the X and Y coordinates of the centers of the first
% and last columns and first and last rows.
if nargs == 1
   R = args{1};
   rasterSize = R.RasterSize;
   
   if R.CoordinateSystemType == "planar"
      
      [X, Y] = R.intrinsicToWorld([1, R.RasterSize(1)], [1, R.RasterSize(2)]);      
      XTicks = X(1):R.CellExtentInWorldX:X(2);
      YTicks = Y(2):R.CellExtentInWorldY:Y(1);

      % This should be equivalent
      % [X, Y] = R.worldGrid;
      % X = [min(X(:)), max(X(:))];
      % Y = [max(Y(:)), min(Y(:))];
   else
      
      X = R.intrinsicXToLongitude([1 rasterSize(2)]);
      Y = R.intrinsicYToLatitude( [1 rasterSize(1)]);

      % [Y, X] = R.geographicGrid;
   end
elseif nargs == 2
   % [X, Y] = prepareMapGrid(X, Y);
   [XTicks, YTicks] = gridvec(varargin{1}, varargin{2});
   X = [min(XTicks(:)) max(XTicks(:))];
   Y = [max(YTicks(:)) min(YTicks(:))];
   
   %Y = [min(Y(:)) max(Y(:))];
end

% prep ticks
numticks = min(numel(XTicks), 10);
XTicks = sort(XTicks(1:round(numel(XTicks)/numticks):end));
YTicks = sort(YTicks(1:round(numel(YTicks)/numticks):end));

% X and Y are two-element vectors representing the coordinates of the first and
% last pixel centers. X(1), Y(1) = the upper left pixel, X(2), Y(2) = the lower
% right pixel 
H = image(Z, 'XData', X, 'YData', Y, 'CDataMapping', 'scaled', 'Parent', ax);

% For reference, this would work too, but X, Y might need to be the coordinates
% H = imagesc(X, Y, Z);
% set(gca,'YDir','normal'); 
            
% Override the automatic reversal of YDir by image.
set(ax, 'Ydir', 'Normal', 'XTick', XTicks, 'YTick', YTicks, 'TickLength', [0 0]);
grid off
axis image

if nargout == 1
   varargout{1} = H;
end

% Check that X,Y are defined correctly
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
