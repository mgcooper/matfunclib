function h = formatPlotMarkers(varargin)
    
    scatterFill     = true;
    if nargin == 1
       %Children    = varargin{1};  % plot handles (not axis)
       scatterFill  = varargin{1};  % true means fill every point
    else
        ax          = gca;
        Children    = allchild(ax);
    end
    
    % this should work for cases where Children comes up empty
    try
        linesWithMarkers    = Children(~ismember({Children.Marker},'none'));
    catch
        h = [];
        return;
    end
    
    for n = 1:numel(linesWithMarkers)
        
        thisLine    = linesWithMarkers(n);
        numPoints   = numel(thisLine.XData);
        
        if scatterFill == true
            markerIdx   = 1:numPoints;
            markerSz    = 6;
        else
            markerIdx = round(linspace(1,numPoints,10),0);
            markerSz    = 8;
        end
        markerColor = thisLine.Color;
%         markerColor = thisLine.MarkerEdgeColor;
        
        set(thisLine,   'MarkerIndices',        markerIdx,      ...
                        'MarkerSize',           markerSz,       ...
                        'MarkerEdgeColor',      'none',         ...
                        'MarkerFaceColor',      markerColor,    ...
                        varargin{:});
    end
end

