function h = abline(varargin)
   %ABLINE Draw a linear trend line on the current figure
   %
   %
   % See also: lsline


   % NOTE: I copied the contents of refline.m here, to modify the function so
   % it plots the lsline using the same color as the scatter/plot markers.
   % Then, because refline.m calls lsline.m, I copied lsline.m and defined the
   % function mylsline.m at the bottom of this function. Note that lsline.m
   % (and therefore mylsline.m) both call refline.m to draw the line, but I
   % guess that's fine. See the code block partway down where I started
   % setting up a method to find the scatter/plot marker colors, then I
   % realized I could take advantage of the methods in lsline.m to get the
   % colors, since lsline only gets called when the colors are not provided

   % To use a different fitting method, I would need to NOT call refline from
   % mylsline


   [ax,args,nargin] = axescheck(varargin{:});

   %     if nargin >2  % mgc commented out to allow line plot specs
   %         error(message('MATLAB:TooManyInputs'));
   %     end
   if isempty(ax)
      ax = gca;
   end

   if nargin == 0
      hh = mylsline(ax);
      if nargout >0
         h = hh;
      end
      return;
   end

   if nargin == 1
      if max(size(args{:})) == 2
         slope = args{1}(1);
         intercept = args{1}(2);
      else
         slope = args{1};
         intercept = 0;
      end
   end

   if nargin >= 2                          % mgc changed ==2 to >=2
      slope = args{1};
      intercept=args{2};
      args=args(3:end);                   % mgc added this line
   end

   % -------------------------------------------------------------------------
   % NOTE: the problem this tried to solve is when abline(a,b) is called but
   % no color is specified, but in that case, i'll just have to specifiy the
   % color, because otherwise, there could be multiple scatter plots and i
   % have no way of knowning whcuih ab line is being plotted, and besides, the
   % fucntion does that automatically, no need to pass in a,b, only when a non
   % least squares fit is used, then i'll just have to pass in the color

   % --- this is mostly finished but instead, I use the functionality of
   % lsline. I considered breaking out the stuff in lsline that finds the
   % scatter/plot objects to define a new function, but it was complicated by
   % the Z stuff, but could be a good function to have at some point.

   %     % mgc, if args is empty, that means no plot spec's were given, so try
   %     % to match the abline color to the scatter/plot color. this borrows
   %     % from the lsline function below, but is probably much less robust
   %     if isempty(args)
   %
   %         % first check for scatter plots
   %         ch  = get(ax,'Children');
   %         sh  = findobj(ch,'flat','Type','scatter');
   %         if ~isempty(sh)                     % scatter plots were found
   %             cc  = cell2mat({sh.CData}.');   % get the plotted colors
   %         else                                % no scatter plots were found
   %             lh  = findobj(ch,'Type','line');
   %             if ~isempty(lh)
   %                 cc = lh.Color;
   %             end
   %         end
   %     end
   % -------------------------------------------------------------------------

   xlimits = get(ax,'Xlim');
   ylimits = get(ax,'Ylim');

   np = get(ancestor(ax,'Figure'),'NextPlot');
   set(ancestor(ax,'Figure'),'NextPlot','add');

   if all(isfinite(xlimits))
      xdat = xlimits;
   else
      xdat = ax.DataSpace.XLim;
   end
   ydat = intercept + slope.*xdat;
   maxy = max(ydat);
   miny = min(ydat);

   if maxy > ylimits(2)
      if miny < ylimits(1)
         set(ax,'YLim',[miny maxy]);
      else
         set(ax,'YLim',[ylimits(1) maxy]);
      end
   else
      if miny < ylimits(1)
         set(ax,'YLim',[miny ylimits(2)]);
      end
   end

   if nargout == 1
      h = line(xdat,ydat,'Parent',ax);
      set(h,'LineStyle','-',args{:});          % mgc added args{:}
   else
      hh = line(xdat,ydat,'Parent',ax);
      set(hh,'LineStyle','-',args{:});         % mgc added args{:}
   end

   set(ancestor(ax,'Figure'),'NextPlot',np);

end

function h = mylsline(AX)
   % LSLINE Add least-squares fit line to scatter plot.
   %   LSLINE superimposes the least squares line in the current axes
   %   for plots made using PLOT, LINE, SCATTER, or any plot based on
   %   these functions.  Any line objects with LineStyles '-', '--',
   %   or '.-' are ignored.
   %
   %   LSLINE(AX) plots into AX instead of GCA.
   %
   %   H = LSLINE(...) returns the handle to the line object(s) in H.
   %
   %   See also POLYFIT, POLYVAL, REFLINE.

   %   Copyright 1993-2014 The MathWorks, Inc.


   % Find any line objects that are descendents of the axes.
   if nargin==0
      AX = gca;
   end
   AxCh = get(AX,'Children');
   lh = findobj(AxCh,'Type','line');
   % Ignore certain continuous lines.
   if ~isempty(lh)
      style = get(lh,'LineStyle');
      if ~iscell(style)
         style = cellstr(style);
      end
      ignore = strcmp('-',style) | strcmp('--',style) | strcmp('-.',style);
      lh(ignore) = [];

      % decided not to use this method, instead its all done in the hh(k) loop
      % below, but keeping just in case
      %         % mgc: get colors of the plotted markers, start by checking if a
      %         % markerfacecolor exists
      %         if
      %         clh = lh.Color;
   end

   % Find hggroups that are immediate children of the axes, such as plots made
   % using SCATTER.
   hgh = findobj(AxCh,'flat','Type','scatter');

   % Ignore hggroups that don't expose both XData and YData.
   if ~isempty(hgh)
      ignore = ~isprop(hgh,'XData') | ~isprop(hgh,'YData');
      hgh(ignore) = [];

      % decided not to use this method, instead its all done in the hh(k) loop
      % below, but keeping just in case
      % mgc - get the colors of the plotted scatter groups
      chgh = cell2mat({hgh.CData});
   end

   % % decided not to use this method, instead its all done in the hh(k) loop
   % % below, but keeping just in case
   %     % mgc concatenate the colors
   %     if exist('clh','var') && exist('chgh','var')
   %         cc = [clh;chgh];
   %     elseif exist('clh','var') && ~exist('chgh','var')
   %         cc = clh;
   %     elseif ~exist('clh','var') && exist('chgh','var')
   %         cc = chgh;
   %     else
   %         cc = []; % should be handled below where numlines == 0
   %     end

   hh = [lh;hgh];
   numlines = length(hh);
   if numlines == 0
      warning(message('stats:lsline:NoLinesFound'));
      hlslines = [];
   else
      for k = 1:length(hh)
         if isprop(hh(k),'ZData')
            zdata = get(hh(k),'ZData');
            if ~isempty(zdata) && ~all(zdata(:)==0)
               warning(message('stats:lsline:ZIgnored'));
            end
         end
         % Extract data from the points we want to fit.
         xdat = get(hh(k),'XData'); xdat = xdat(:);
         ydat = get(hh(k),'YData'); ydat = ydat(:);
         ok = ~(isnan(xdat) | isnan(ydat));

         % mgc commented out default version below this and added test
         % to determine if MarkerFaceColor is a property to use that
         % first, if it's a scatter plot, then check if MarkerFaceColor
         % is 'flat', which is what it will get set if 'filled' is used
         % in call to scatter, then check if it's 'none' and use 'color'
         % first, and if not, try marker edge color. NOTE: THIS could
         % probably be simplified by separating the checks into line
         % type and scatter types, and/or by first checking for 'flat'
         % marker face/edge and using CData
         if isprop(hh(k),'MarkerFaceColor')
            if strcmp(hh(k).MarkerFaceColor,'flat')
               datacolor = hh(k).CData;
            elseif strcmp(hh(k).MarkerFaceColor,'none')
               % if plot(x,y,'o','MarkerEdgeColor',c(1,:)) is called,
               % then hh(k).Color has the default color order value
               % that may not match the color given, so i switched the
               % first check to go for MarkerEdgeColor instead of
               % Color, but this could create problems
               if isprop(hh(k),'MarkerEdgeColor')
                  % this occurs if 'scatter' is called without any
                  % color, so the default setting is a hollow circle
                  if strcmp(hh(k).MarkerEdgeColor,'flat')
                     datacolor = hh(k).CData;
                  elseif strcmp(hh(k).MarkerEdgeColor,'auto') || ...
                        strcmp(hh(k).MarkerEdgeColor,'none')
                     % this occurs if plot(x,y3,'o'), and is nested this
                     % deep because of preference for markerfacecolor,
                     % note this replicates the elseif below that occurs
                     % if markerfacecolor
                     if isprop(hh(k),'Color')
                        datacolor = get(hh(k),'Color');
                     end
                  else
                     datacolor = hh(k).MarkerEdgeColor;
                  end
               elseif isprop(hh(k),'Color')
                  datacolor = get(hh(k),'Color');
               end

               %                     this is the setup before above change
               %                     if isprop(hh(k),'Color')
               %                         datacolor = get(hh(k),'Color');
               %                     elseif isprop(hh(k),'MarkerEdgeColor')
               %                         % this occurs if 'scatter' is called without any
               %                         % color, so the default setting is a hollow circle
               %                         if strcmp(hh(k).MarkerEdgeColor,'flat')
               %                             datacolor = hh(k).CData;
               %                         elseif strcmp(hh(k).MarkerEdgeColor,'auto') || ...
               %                                 strcmp(hh(k).MarkerEdgeColor,'none')
               %                             % not sure what to do here if it ever occurs
               %                         else
               %                             datacolor = hh(k).MarkerEdgeColor;
               %                         end
               %                     end
            else
               datacolor = hh(k).MarkerFaceColor;
            end
         elseif isprop(hh(k),'Color')
            datacolor = get(hh(k),'Color');
         else
            datacolor = [.75 .75 .75]; % Light Gray
         end

         %             if isprop(hh(k),'Color')
         %                 datacolor = get(hh(k),'Color');
         %             else
         %                 datacolor = [.75 .75 .75]; % Light Gray
         %             end
         % Fit the points and plot the line.
         beta = polyfit(xdat(ok,:),ydat(ok,:),1);
         hlslines(k) = refline(AX,beta);
         set(hlslines(k),'Color',datacolor);
      end
      set(hlslines,'Tag','lsline');
   end

   if nargout == 1
      h = hlslines;
   end
end
