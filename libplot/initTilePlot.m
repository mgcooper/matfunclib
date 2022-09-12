function [hFig,hTiles] = initTilePlot(tileSpacing,Padding,numTiles)
    
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
        case 3
            if isodd(numTiles)
                nrows   = (numTiles-1)/2;
            else
                nrows   = numTiles/2;
            end
            ncols   = numTiles/nrows;
            % use whatever was passed in
    end
            
    
    % this makes an empty figure if one doesn't exist in the workspace
    hFig = makeFigIfNoneExists;

    % this initializes an empty 
    if isnan(numTiles)
        hTiles = tiledlayout('flow',        'TileSpacing',tileSpacing,  ...
                                            'Padding',Padding);
    else
        hTiles = tiledlayout(nrows,ncols,   'TileSpacing',tileSpacing,  ...
                                            'Padding',Padding);
    end
    
    
%     ishghandle(stored_handle)
    
end