% PLOTDEFAULTS      Apply a range of default values to the current plot
% 
% This class encapsulates common plot operations into one class with
% multiple sizing options which can be customized as desired. PlotDefaults
% always acts on the current plot and current axes.
% 
% Methods:
%   applyDefaultLabels  - apply x,y,z labels with a latex interpreter
%   applySizes          - apply one of three pre-set size definitions to
%                         the tick, label and legend. Options are, 'std',
%                         'med', 'big'.
% 
% Static data:
%   colours             - set of arrays containing RGB data for different
%                         colours
% 
% Examples:
%   PlotDefaults.applyDefaultLabels
%       Apply default labels to current plot    
%   PlotDefaults.applySizes('std')
%       Apply the standard set of sizes to the current plot.
%   PlotDefaults.colours.blue(:, 1)
%       Fetch the 1st shade of blue from the colour palette.
% 
% Copyright (C) Matthew Sparkes 2022 - 2023





classdef PlotDefaults < handle

    properties (Constant)
        colours = PlotColours.colours;
        std = PlotSizes.stdInfo;
        med = PlotSizes.medInfo;
        big = PlotSizes.bigInfo;
    end


    methods (Static)
        applyDefaultLabels;
        applySizes(sizes);
        applyEqualAxes(axes_char);
        col = fetchColourByIdx(idx);
    end

    methods (Static)
        function setLatexDefault
            set(groot, 'defaultAxesTickLabelInterpreter','latex');
            set(groot, 'defaultLegendInterpreter','latex');
        end
    end
end



