function applySizes(size_name)
%   APPLYSIZES(size_name)   Apply set of standard sizes to current axes.
%
%   applySizes applies a pre-defined sizing to the axes ticks, axes labels,
%   and legend. Sizes are defined in subclasses of the SizesClass and can
%   be modified to suit your own preferences.
%
%   Usage: With the desire plot selected, simply type,
%       PlotDefaults.applySizes(size_name)
%           where size_name can be 'std', 'med', 'big'.
%
%   Copyright (C) Matthew Sparkes 2022 - 2023

    % Validate input
    validatestring(size_name, {'std', 'med', 'big'});

    % Fetch current axes
    ax = gca;
    

    switch size_name

        case 'std'

            ax.FontSize = PlotDefaults.std.FontSizeTick;

            ax.XLabel.FontSize = PlotDefaults.std.FontSizeLab;
            ax.YLabel.FontSize = PlotDefaults.std.FontSizeLab;
            ax.ZLabel.FontSize = PlotDefaults.std.FontSizeLab;

            if ~isempty(ax.Legend)
                ax.Legend.FontSize = PlotDefaults.std.FontSizeLeg;
            end

        case 'med'

            ax.FontSize = PlotDefaults.med.FontSizeTick;

            ax.XLabel.FontSize = PlotDefaults.med.FontSizeLab;
            ax.YLabel.FontSize = PlotDefaults.med.FontSizeLab;
            ax.ZLabel.FontSize = PlotDefaults.med.FontSizeLab;

            if ~isempty(ax.Legend)
                ax.Legend.FontSize = PlotDefaults.med.FontSizeLeg;
            end

        case 'big'
            ax.FontSize = PlotDefaults.big.FontSizeTick;

            ax.XLabel.FontSize = PlotDefaults.big.FontSizeLab;
            ax.YLabel.FontSize = PlotDefaults.big.FontSizeLab;
            ax.ZLabel.FontSize = PlotDefaults.big.FontSizeLab;

            if ~isempty(ax.Legend)
                ax.Legend.FontSize = PlotDefaults.big.FontSizeLeg;
            end

    end
end