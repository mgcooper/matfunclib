
function colToReturn = fetchColourByIdx(idx, init_shade)
%   FETCHCOLOURBYIDX(idx, init_shade)   fetchColourByIdx is a methodology
%   to retrieve a colour by index.
%
%   When drawing lines to a figure, it can be desirable to iterate through
%   the colour palette, selecting each sequential colour in turn.
%   fetchColourByIdx implements this idea by dynamically fetching the
%   colours defined in PlotColours and returning an appropriate colour. The
%   initial shade can be defined using the init_shade option.

    arguments
        idx             (1, 1) {mustBePositive}
        init_shade      (1, 1) {mustBeInRange(init_shade, 1, 12)} = 7;
    end
    
    col = zeros(1, 3);

    % Fetch the number of colours defined in PlotColours
    colournames = fields(PlotColours.colours);

    % First element is `colours', so we'll get rid of it
    colournames(1) = [];

    % Fetch number of colours
    N = length(colournames);
    M = length(PlotColours.colours.blue(:, 1));

    % Find shade
    shade = init_shade + 2*floor(idx/N);

    if shade > M
        error('Initial shade too large');
    else
        colidx = mod(idx, N);
        if colidx == 0
            colidx = N;
        end
        colToReturn = PlotColours.colours.(colournames{colidx})(shade, :);
        
    end
end