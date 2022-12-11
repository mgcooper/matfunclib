function applyEqualAxes(axes_char)
%   APPLYEQUALAXES  Apply equal aspect ratios desired axes.
%
%   Usage: Select desired axes and type the command,
%       PlotDefaults.applyEqualAxes(axes_string)
%           where axes_string is a character array of axes to be equalised.
%
%   Example: Set x-y axes to be equal
%       PlotDefaults.applyEqualAxes('xy')
%
%   Example: Set x-z axes to be equal
%       PlotDefaults.applyEqualAxes('xz')
%
%   Example: Set x-y-z axes to be equal
%       PlotDefaults.applyEqualAxes('xyz')
%   OR  PlotDefaults.applyEqualAxes


    % Data select
    axesbool = [false, false, false];

    % Validate arguments
    if nargin > 0
        validchar = ~isempty(axes_char) && length(axes_char) <= 3 && ischar(axes_char);

        if ~validchar
            error('Invalid input: must be char of length less than 3')
        end

        for i = 1:length(axes_char)
            axesbool = axesbool | strcmp(axes_char(i), {'x', 'y', 'z'});
        end

        if ~any(find(axesbool))
            warning('No valid input. Char must contain x, y or z')
        end
    else
        axesbool = [1, 1, 1];
    end

    % Fetch current data aspect ratio
    ax = gca;

    % Fetch maximum desired aspect ratio
    D = ax.DataAspectRatio(axesbool);

    % Apply equal axes to each
    ax.DataAspectRatio(axesbool)    = max(D);

    

end