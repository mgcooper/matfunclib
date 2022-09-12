function h = figformat(varargin)
   
   p               = MipInputParser;
   p.FunctionName  = 'figformat';
   p.CaseSensitive = false;
   p.KeepUnmatched = true;

   p.addParameter(    'reformat',           false,      @(x)islogical(x)  );
   p.addParameter(    'textfontsize',       14,         @(x)isscalar(x)   );
   p.addParameter(    'axesfontsize',       16,         @(x)isscalar(x)   );
   p.addParameter(    'labelfontsize',      16,         @(x)isscalar(x)   );
   p.addParameter(    'legendfontsize',     14,         @(x)isscalar(x)   );
   p.addParameter(    'textfontname',       'verdana',  @(x)ischar(x)     );
   p.addParameter(    'axesfontname',       'verdana',  @(x)ischar(x)     );
   p.addParameter(    'labelfontname',      'verdana',  @(x)ischar(x)     );
   p.addParameter(    'legendfontname',     'verdana',  @(x)ischar(x)     );
   p.addParameter(    'legendlocation',     'best',     @(x)ischar(x)     );
   p.addParameter(    'textinterpreter',    'latex',    @(x)ischar(x)     );
   p.addParameter(    'axesinterpreter',    'latex',    @(x)ischar(x)     );
   p.addParameter(    'labelinterpreter',   'latex',    @(x)ischar(x)     );   
   p.addParameter(    'legendinterpreter',  'latex',    @(x)ischar(x)     );
   p.addParameter(    'linelinewidth',      1,          @(x)isscalar(x)   );
   p.addParameter(    'axeslinewidth',      1,          @(x)isscalar(x)   );
   p.addParameter(    'patchlinewidth',     1,          @(x)isscalar(x)   );
   p.addParameter(    'ticklength',         [.015 .02], @(x)isnumeric(x)  );
   p.addParameter(    'suppliedfigure',     gcf,        @(x)isobject(x)   );
   p.addParameter(    'suppliedaxis',       gca,        @(x)isaxis(x)     );
   p.addParameter(    'suppliedline',       [],         @(x)ishandle(x)   );
   p.addParameter(    'xgrid',              'on',       @(x)ischar(x)     );
   p.addParameter(    'ygrid',              'on',       @(x)ischar(x)     );
   p.addParameter(    'xgridminor',         'off',      @(x)ischar(x)     );
   p.addParameter(    'ygridminor',         'off',      @(x)ischar(x)     );

   parse(p,varargin{:});

   reformat       = p.Results.reformat;

    switch reformat
     case true
         h = refigformat(p);
     case false
         h = newfigformat(p);
    end
end


function h = newfigformat(p)
   
   
   textfontsize         = p.Results.textfontsize;
   axesfontsize         = p.Results.axesfontsize;
   labelfontsize        = p.Results.labelfontsize;
   legendfontsize       = p.Results.legendfontsize;
   textfontname         = p.Results.textfontname;
   axesfontname         = p.Results.axesfontname;
   labelfontname        = p.Results.labelfontname;
   legendfontname       = p.Results.legendfontname;
   textinterpreter      = p.Results.textinterpreter;
   axesinterpreter      = p.Results.axesinterpreter;
   labelinterpreter     = p.Results.labelinterpreter;
   legendinterpreter    = p.Results.legendinterpreter;
   legendlocation       = p.Results.legendlocation;
   linelinewidth        = p.Results.linelinewidth;
   axeslinewidth        = p.Results.axeslinewidth;
   patchlinewidth       = p.Results.patchlinewidth;
   ticklength           = p.Results.ticklength;
   suppliedaxis         = p.Results.suppliedaxis;
   suppliedfigure       = p.Results.suppliedfigure;
   suppliedline         = p.Results.suppliedline;
   unmatched            = p.Unmatched;
   
   
   % might use this:
   % allChildren    = findobj(allchild(gcf));
   % htext    = findobj(allChildren,'Type','Text') 
   
   %~~~~~~~~~~~~~~~~~~~~
   % GENERAL PROPERTIES
   %~~~~~~~~~~~~~~~~~~~~
   
   % I turned all of these off b/c they are set now in startup
   % set(findall(gcf,'-property','LineWidth'),'LineWidth',1);
   % set(findall(gcf,'-property','FontSize'),'FontSize',16)
   % set(findall(gcf,'-property','TickDir'),'TickDir','out')
   % set(findall(gcf,'-property','XMinorTick'),'XMinorTick','on')
   % set(findall(gcf,'-property','YMinorTick'),'YMinorTick','on')
   
   % except these
%    set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter',labelinterpreter);
%    set(findall(gcf,'-property','Interpreter'),'Interpreter',axesinterpreter);
   
   %~~~~~~~~~~~~~~~~~~~~
   % AXES PROPERTIES
   %~~~~~~~~~~~~~~~~~~~~
   
   % test - setting to 'outerposition' should prevent x/ylabel cutoff
   set(suppliedaxis,'PositionConstraint','outerposition')
%    set(suppliedaxis,'PositionConstraint','innerposition')
   
   suppliedaxis.YLabel.Interpreter = labelinterpreter;
   suppliedaxis.XLabel.Interpreter = labelinterpreter;
   set(suppliedaxis,'FontName',axesfontname);
   set(suppliedaxis,'FontSize',axesfontsize);
   set(suppliedaxis,'LineWidth',axeslinewidth);
   set(suppliedaxis,'TickLabelInterpreter',axesinterpreter)
   set(suppliedaxis,'TickLength',ticklength);
   
%    % it might be necessary to do this if we have multiple axes, b/c the
%    default suppliedaxis is gca
%    hAxes    = findobj(gcf,'Type','Axes');
%    set(hAxes,'FontName',axesfontname);
%    set(hAxes,'FontSize',axesfontsize);
%    set(hAxes,'LineWidth',axeslinewidth);
%    set(hAxes,'TickLabelInterpreter',axesinterpreter)
%    set(hAxes,'TickLength',ticklength);
   
   
   
   % other axis props:
   % Box, Color, Colormap, FontAngle, GridAlpha, GridColor, etc.
   % XAxis, XAxisLocation, XColor, XDir, XGrid, XLabel, XLim, XMinorGrid,
   % XMinorTick, XScale, XTick, XTickLabel, XTickLabelRotation
   
   %~~~~~~~~~~~~~~~~~~~~
   % LEGEND PROPERTIES
   %~~~~~~~~~~~~~~~~~~~~
   hLegend = findobj(gcf,'Type','Legend');
   set(hLegend,'FontSize',legendfontsize);
   set(hLegend,'Location',legendlocation);
   set(hLegend,'Interpreter',legendinterpreter);
 
   % both of these will thicken the lines in the plot AND legend
   % hLines = findobj(gca,'Type','line');
   % hLines = findall(gcf,'Type','line');
   % set(hLines,'LineWidth',3)
 
   % this will shorten the legend lines, but to thicken them the legend 
   % must be created with [hl,icons,plots,txt] = legend
 
   numPlots    = numel(hLegend);
   for n = 1:numPlots  
      hLegend(n).ItemTokenSize = [18,18];  
      hLegend(n).LineWidth = 1;              % make the box thinner
   end

   % this might work to run figformat after all subplots are finished
   % hAxes = findobj(gcf,'Type','Axes');
    
   %~~~~~~~~~~~~~~~~~~~~
   % LINE /PATCH OBJECTS 
   %~~~~~~~~~~~~~~~~~~~~
   if isempty(suppliedline)
      % apply formatting to all lines/patches
      hLines   = findobj(gcf,'Type','Line');
      hPatch   = findobj(gcf,'Type','Patch');

      set(hPatch,'LineWidth',patchlinewidth);
      set(hLines,'LineWidth',linelinewidth);
   else
      set(suppliedline,'LineWidth',linelinewidth);
   end
   
   %~~~~~~~~~~~~~~~~~~~~
   % TEXT OBJECTS
   %~~~~~~~~~~~~~~~~~~~~

   hText    = findobj(gcf,'Type','Text');
   set(hText,'Interpreter',textinterpreter);
   
   for n = 1:numel(hText)
      hText(n).FontSize = textfontsize;
   end
   
   % this was on the community forums but above seems to work 
   % set(findobj(allchild(gcf),'Type','AnnotationPane'),...
   % 'HandleVisibility','on')
   % findobj(gcf,'Type','textboxshape') 
   
   %~~~~~~~~~~~~~~~~~~~~
   % NEW AXIS
   %~~~~~~~~~~~~~~~~~~~~
    % add a solid box without tick marks around the right and upper
    ax1 = suppliedaxis;
    if iscategorical(ax1.XLim)
        ax2 = axes('Position',get(ax1,'Position'),'Box','on','Color','none',...
                'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[],      ...
                'YLim',get(ax1,'YLim'));
        set(gcf,'CurrentAxes',ax1);
        linkaxes([ax1 ax2],'y');
        box off 
        % link axes in case of zooming
    else
        % this fixed misalignment following addonetoone
      % ax1pos  = get(ax1,'Position');
                                                                pause(0.001)
        ax1pos  = plotboxpos(ax1);                              pause(0.001)
        ax1xlim = get(ax1,'XLim');
        ax1ylim = get(ax1,'YLim');

        ax2 = axes('Position',ax1pos,'Box','on','Color','none','XTick',[],  ...
                'XTickLabel',[],'YTick',[],'YTickLabel',[]);    pause(0.001)

        % moved these here to deal with datetime error but iddn't work
        ax2.YLim = ax1ylim; 
        
        % link axes in case of zooming 
        if ~isdatetime(ax1xlim)
            ax2.XLim = ax1xlim;
            linkaxes([ax1 ax2],'xy');
        end
        pause(0.001)
        set(gcf,'CurrentAxes',ax1);
        % axes(ax1) % set original axes as active
        
        box off 
    end

   %set(gca,'XGrid','on','YGrid','on')
    pause(0.001)
    ax2.Position = plotboxpos(ax1);
    pause(0.001)
    
    % new - format plot markers. NOTE: this only works if I want to plot a
    % marker on a line and have the markers filled every few points,
    % whereas if I want plot(x,y,'o') to basically act like
    % scatter(...,'filled'), then it doesn't work, so I need an option
    
    % i commented this out after improving formatPlotMarkers with
    % inputparser, which makes it easy enough to call. That functionality
    % needs to be ported here
  % formatPlotMarkers;
    
    h.figure            = gcf;
    h.mainAxis          = ax1;
    h.backgroundAxis    = ax2;
    h.legend            = hLegend;
    
end

function ff = refigformat(arg1,arg2)
    
    % parse input
    if isstruct(arg1)       % assume it's the figformat handle struct
        ff  = arg1;
        cmd = arg2;     
    elseif ischar(arg1)     % assume it's the command
        cmd = arg1;
        ff  = arg2;
    end

    switch cmd
        case {'align','realign','alignaxes'}
            ff.backgroundAxis.Position = plotboxpos(ff.mainAxis);
            ff.mainAxis.Position = plotboxpos(ff.backgroundAxis);
            
            
        case {'format','reformat'}
            
            ff = resetFormat(ff);
            
        case {'legendmarkeradjust','legendlines','formatlegend'}
            ff = reformatLegend(ff);
            
        case {'formatticks','tickformat','ticks','ticklabels'}
            ff = reformatTickLabels(ff);
                
    end

    % NOTE: in the case of multiple plots called in a row, if the axes git
    % misaligned, try this:
    % h1.backgroundAxis.Position = h1.mainAxis.Position;
    % h2.backgroundAxis.Position = h2.mainAxis.Position;

end

function ff = resetFormat(ff)
    
    set(findall(gcf,                                                ...
                    '-property','Interpreter'),                     ...
                    'Interpreter','latex');
                    
    set(findall(gcf,                                                ...
                    '-property','TickLabelInterpreter'),            ...
                    'TickLabelInterpreter','latex');
    
end


function ff = reformatLegend(ff)
    

%     hLegend = findobj(ff.figure, 'Type', 'Legend');
%     hLegend.ItemTokenSize = [18,18];
%     hLegend.LineWidth = 1;
%     
%     hLines = findobj(hlegend,'Type','line')
  
end

function ff = reformatTickLabels(ff)
    
    % not functional, just somewhere to start
    ff.mainAxis.XAxis.TickLabels = compose('%g',ff.mainAxis.XAxis.TickValues);
    ff.mainAxis.YAxis.TickLabels = round(ff.mainAxis.YAxis.TickValues-1,1);
    ff.backgroundAxis.Position   = ff.mainAxis.Position;
end

% this would work to modify all axes e..g in a subplot, but it messes with
% the legend so I need to figure out how to add them back
% axs = findobj(gcf,'Type','axes');
% for n = 1:numel(axs)
%     
%     ax2 = axes('Position',get(axs(n),'Position'),'Box','on','Color','none',    ...
%             'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[],      ...
%             'XLim',get(axs(n),'XLim'),'YLim',get(axs(n),'YLim'));
%     axes(axs(n)) % set original axes as active
%     linkaxes([axs(n) ax2],'xy') % link axes in case of zooming
%     box off 
% end

% keeping this for reference in case it's needed
% colorbar('TickLabelInterpreter', 'latex')

% I like lines at 1.5 but circles at 1, but this doesn't work
% hlines = findobj(gca,'Type','line');
% hmarks = findobj(gca,'Type','marker');
% set(hlines,'LineWidth',1)
% set(hmarks,'LineWidth',1)

% this is an older way i used to set ticks and legend text to latex
% set ticks to latex
% hticks = findall(0,'-property','TickLabelInterpreter'); 
% hlegend = findobj(gcf,'Type','Legend');
% set(hticks,'TickLabelInterpreter','Latex')
% set(hlegend,'Interpreter','latex');
% 
% a=findobj(gcf,'type','axe')
% set(get(a,'XLabel'),'string')
% a.XLabel.Interpreter


% this is an older way i used to set ticks and legend text to latex
% set ticks to latex
% hticks = findall(0,'-property','TickLabelInterpreter'); 
% hlegend = findobj(gcf,'Type','Legend');
% set(hticks,'TickLabelInterpreter','Latex')
% set(hlegend,'Interpreter','latex');
% 
% a=findobj(gcf,'type','axe')
% set(get(a,'XLabel'),'string')
% a.XLabel.Interpreter

