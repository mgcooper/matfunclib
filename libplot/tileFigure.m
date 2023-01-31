function [hFig,hTiles] = tileFigure(tileSpacing,Padding,numTiles,varargin)

% defaults
switch nargin
   case 0
      tileSpacing = 'compact';
      Padding     = 'compact';
      numTiles    = nan;
   case 1
      Padding     = 'compact';
      numTiles    = nan;
   case 2
      numTiles    = nan;
   case {3,4}
      if isodd(numTiles)
         nrows   = (numTiles-1)/2;
      else
         nrows   = numTiles/2;
      end
      ncols   = numTiles/nrows;
      % use whatever was passed in
end

if nargin == 4
   h = varargin{1};
else
   h = figure;
end

% this finds the match to the figure handle h or makes an empty figure if one
% doesn't exist in the workspace 
if isempty(findobj(allchild(0), 'flat', 'type', 'figure'))
   hFig = figure;
else
   allfigs = findobj(allchild(0), 'flat', 'type', 'figure');
   hFig = allfigs(allfigs == h);
end

% might need a check for older graphics objects
% ishghandle(stored_handle)

% this initializes an empty
if isnan(numTiles)
   hTiles = tiledlayout('flow','TileSpacing',tileSpacing,'Padding',Padding);
else
   hTiles = tiledlayout(nrows,ncols,'TileSpacing',tileSpacing,'Padding',Padding);
end

nexttile;

