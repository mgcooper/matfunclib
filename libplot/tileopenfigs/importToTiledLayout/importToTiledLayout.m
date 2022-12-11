function importToTiledLayout(figNames, tiledLayoutArray)
% IMPORTTOTILEDLAYOUT(figNames, tiledLayout)
% Creates a tiled layout from the cell array figNames, which should contain
% strings with the saved figures for insertion to a tiled layout. I.e;
%   figNamesExample = {'testFig1.fig', 'testFig2.fig'}
% An n-by-1 tiledlayout will be generated from the saved figures. Add the
% optional argument, tiledLayoutArray to specify the layout, i.e.
%   tiledLayoutArrayExample = [2, 2];
%
% Version 1.0, (Nov, 2021). Tested in 2021a.
% (c) Matthew Sparkes
% email: matthew.sparkes@york.ac.uk
    
    % Find length
    n = length(figNames);
    % Check nargin; default to long layout.
    if nargin < 2
        tiledLayoutArray = [n, 1];
    end
    
    % Rows, columns.
    rows = tiledLayoutArray(1);
    cols = tiledLayoutArray(2);
    
    for i = 1:n
        % Open fig, save handle to h, don't show.
        h{i} = openfig(figNames{i}, 'invisible');
        ax = gca;
        % Get all handles.
        fig{i} = get(ax, 'children');
    end
    
    % Create new tiled layout
    figure
    tiledlayout(rows, cols);
    
    for i = 1:n
        % Cycle through, getting handles to tiles
        t = nexttile;
        copyobj(fig{i},t);
        % Close invisible figures.
        close(h{i})
        
    end
end