function monthplot(data, varargin)
   %MONTHPLOT Plot data against an axis from 1:12 labeled with months MMM
   %
   %  monthplot(data, varargin)
   %
   % See also

   % I decided it makes more sense for this to just plot 1:12 months, and
   % another, general function could accept arbitrary time inputs and date
   % formats

   % parse inputs
   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.addRequired('data', @isnumeric);
   parser.addParameter('useax', nan, @isaxis);
   parser.addParameter('wateryear', false, @islogical);
   parser.addParameter('plottype', 'line', @ischar);
   parser.parse(data, varargin{:});

   useax = parser.Results.useax;
   plottype = parser.Results.plottype;
   wateryear = parser.Results.wateryear;

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
         plot(useax,1:12,data);
      case 'hist'
         histogram(useax,data);
   end
   axis tight
   set(useax, 'xlim', [1 12], 'xtick', 1:12, 'xticklabel', months,...
      'xticklabelrotation', 45);

   % % old method

   % function [ h ] = monthplot( data,yri,moi,dayi,yrf,mof,dayf,dt,dateformat )
   % dt is the timestep of the actual data, in hours
   % dx is the timestep you want labeled on the figure

   % legacy = false;
   % if legacy == true
   %    t = timebuilder(yri,moi,dayi,yrf,mof,dayf,dt);
   %    t2 = timebuilder(yri,moi,yrf,mof);
   %    [si,ei] = dateInds(yri,moi,dayi,yrf,mof,dayf,t);
   %    xdates = t(:,7);
   %    xticks = t2(:,7);
   %    xlabels = datestr(xticks,dateformat);
   %
   %    h = plot(xdates,data);
   %
   %    set(gca, 'box', 'off' , ...
   %       'xtick'         ,   xticks                      , ...
   %       'xticklabel'    ,   xlabels                      , ...
   %       'xlim'          ,   [xticks(1) xticks(end)]     );
   % end
end
