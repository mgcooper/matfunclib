function monthplot(data, varargin)
   %MONTHPLOT Plot data against an axis from 1:12 labeled with months MMM
   %
   %  monthplot(data)
   %  monthplot(data, valid_plot_parampairs)
   %  monthplot(data, 'useax', ax, valid_plot_parampairs)
   %  monthplot(data, 'wateryear', true, valid_plot_parampairs)
   %  monthplot(data, 'plottype', 'hist', valid_hist_parampairs)
   %
   %  MONTHPLOT(DATA) plots values 1:12 on the x-axis against DATA on the
   %  y-axis, then labels the x-axis ticks by calendar-year month names.
   %
   %  MONTHPLOT(DATA, VALID_PLOT_PARAMPAIRS) also passes VALID_PLOT_PARAMPAIRS
   %  to the plot function.
   %
   % See also

   % parse inputs
   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.KeepUnmatched = true;
   parser.addRequired('data', @isnumeric);
   parser.addParameter('useax', nan, @isaxis);
   parser.addParameter('wateryear', false, @islogical);
   parser.addParameter('plottype', 'line', @ischar);
   parser.parse(data, varargin{:});

   useax = parser.Results.useax;
   plottype = parser.Results.plottype;
   wateryear = parser.Results.wateryear;

   % These must be valid name-value parameters accepted by 'plot' function.
   namedargs = namedargs2cell(parser.Unmatched);

   months = load('months.mat').('months');

   if wateryear == true
      months = [months(10:12) months(1:9)];
   end

   if numel(data(:)) ~= 12 && ~strcmp(plottype, 'hist')
      error('data must be a vector of length 12')
   end

   if isnan(useax)
      useax = gca;
   end

   switch plottype
      case 'line'
         plot(useax, 1:12, data, namedargs{:});
         formatPlotMarkers
      case 'hist'
         histogram(useax, data, namedargs{:});
   end
   axis tight
   set(useax, 'xlim', [1 12], 'xtick', 1:12, 'xticklabel', months,...
      'xticklabelrotation', 45);
end
