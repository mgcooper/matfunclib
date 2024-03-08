function h = cumulplot(t,y,varargin)
   %CUMULPLOT cumulative plot
   %
   %  h = cumulplot(t,y,varargin)
   %
   % See also

   [t, y, useax, figpos, ytext, xtext, titletext, legendtext, varargs] = ...
      parseinputs(t, y, mfilename, varargin{:})

   % for now, convert to datenums
   if isdatetime(t)
      %t = datenum(t);
      t = year(t);
   end

   inan = isnan(y);
   ycumul = cumsum(y,'omitnan');
   ycumul = setnan(ycumul,inan);
   ycumul = ycumul-ycumul(1,:);

   % if an axis was provided, use it, otherwise make a new figure
   if not(isaxis(useax))
      h.figure = figure('Position',figpos);
      useax = gca;
   end

   if isempty(varargs)
      h.plot = plot(useax,t,ycumul,'-o'); hold on;
      %h.scatter = myscatter(t,ycumul,rgb('green'));
   else
      h.plot = plot(useax,t,ycumul,varargs{:});
   end

   formatPlotMarkers; hold on; axis tight
   ylabel(ytext); xlabel(xtext); title(titletext); legend(legendtext);
   h.ax = gca;
end

function [t, y, useax, figpos, ytext, xtext, titletext, legendtext, varargs] = ...
      parseinputs(t, y, mfilename, varargin)

   dpos = [321 241 512 384]; % default figure size
   parser = inputParser();
   parser.FunctionName = mfilename;
   parser.PartialMatching = true;
   parser.addRequired('t', @isdatelike);
   parser.addRequired('y', @isnumeric);
   parser.addParameter('ylabeltext', '', @ischar);
   parser.addParameter('xlabeltext', '', @ischar);
   parser.addParameter('titletext', '', @ischar);
   parser.addParameter('legendtext', '', @ischar);
   parser.addParameter('figpos', dpos, @isnumeric);
   parser.addParameter('useax', nan, @isaxis);
   parser.parse(t, y, varargin{:});

   useax = parser.Results.useax;
   figpos = parser.Results.figpos;
   ytext = parser.Results.ylabeltext;
   xtext = parser.Results.xlabeltext;
   titletext = parser.Results.titletext;
   legendtext = parser.Results.legendtext;
   varargs = struct2varargin(parser.Unmatched);
end
