
function h = figformat_old(varargin)
    
    switch nargin
        case 1
            error('two inputs required: figformat handle and command');
        case 2
            arg1 = varargin{1};
            arg2 = varargin{2};
            h = refigformat(arg1,arg2);
        case 0
            h = newfigformat;
    end
end


function h = newfigformat
    
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    % set(findall(gcf,'-property','LineWidth'),'LineWidth',1)
    set(findall(gcf,'-property','TickDir'),'TickDir','out')
    set(findall(gcf,'-property','Interpreter'),'Interpreter','latex')
    set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
    set(findall(gcf,'-property','XMinorTick'),'XMinorTick','on')
    set(findall(gcf,'-property','YMinorTick'),'YMinorTick','on')

    hLegend = findobj(gcf,'Type','Legend');         pause(0.001)
    set(hLegend,'FontSize',14);                     pause(0.001)
    set(hLegend,'Location','best');                 pause(0.001)
    
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
    
    % add a solid box without tick marks around the right and upper
    ax1 = gca;
    if iscategorical(ax1.XLim)
        ax2 = axes('Position',get(ax1,'Position'),'Box','on','Color','none',...
                'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[],      ...
                'YLim',get(ax1,'YLim'));    pause(0.001)
        set(gcf,'CurrentAxes',ax1);         pause(0.001)
        linkaxes([ax1 ax2],'y');            pause(0.001)
        box off 
        % link axes in case of zooming
    else
        % this fixed misalignment following addonetoone
      % ax1pos  = get(ax1,'Position');
                                                                pause(0.001)
        ax1pos  = plotboxpos(ax1);                              pause(0.001)
        ax1xlim = get(ax1,'XLim');                              pause(0.001)
        ax1ylim = get(ax1,'YLim');                              pause(0.001)

        ax2 = axes('Position',ax1pos,'Box','on','Color','none','XTick',[],  ...
                'XTickLabel',[],'YTick',[],'YTickLabel',[]);    pause(0.001)

        % moved these here to deal with datetime error but iddn't work
        ax2.YLim = ax1ylim;                                     pause(0.001)
        
        % link axes in case of zooming 
        if ~isdatetime(ax1xlim)
            ax2.XLim = ax1xlim;                                 pause(0.001)
            linkaxes([ax1 ax2],'xy');                           pause(0.001)
        end
        
        set(gcf,'CurrentAxes',ax1);                             pause(0.001)
        % axes(ax1) % set original axes as active
        
        box off 
    end

    set(gca,'XGrid','on','YGrid','on')
    pause(0.001)
    ax2.Position = plotboxpos(ax1);
    pause(0.001)
    
    % new - format plot markers. NOTE: this only works if I want to plot a
    % marker on a line and have the markers filled every few points,
    % whereas if I want plot(x,y,'o') to basically act like
    % scatter(...,'filled'), then it doesn't work, so I need an option
    formatPlotMarkers;
    
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

