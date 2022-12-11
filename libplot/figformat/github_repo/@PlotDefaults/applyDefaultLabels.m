function applyDefaultLabels
%   APPLYDEFAULTLABELS  Apply default labels to current axes
%
%   applyDefaultLabels applies the labels x, y, z to the current axes.
%
%   Usage: Select the desired axes and type the command,
%       PlotDefaults.applyDefaultLabels.

    % Set latex as default
    PlotDefaults.setLatexDefault;

    % Set all labels
    xlabel('$x$', 'Interpreter','latex');
    ylabel('$y$', 'Interpreter','latex');
    zlabel('$z$', 'Interpreter','latex');

end