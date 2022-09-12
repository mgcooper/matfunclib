function h = hyetograph(time,flow,ppt,varargin)
%HYETOGRAPH Plots a discharge rainfall hyetograph
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   p = MipInputParser;
   p.FunctionName='hyetograph';
   p.addRequired('time',@(x)isnumeric(x)|isdatetime(x));
   p.addRequired('flow',@(x)isnumeric(x));
   p.addRequired('ppt',@(x)isnumeric(x));
   p.addOptional('t1',nan,@(x)isnumeric(x)|isdatetime(x));
   p.addOptional('t2',nan,@(x)isnumeric(x)|isdatetime(x));
   p.parseMagically('caller');
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%    "display":"t1",  
   time  = time(:);
   ppt   = ppt(:);
   flow  = flow(:);
   
   if ~isdatetime(time)
      time = datetime(time,'ConvertFrom','datenum');
   end
   
   trim = true;
   if nargin == 3
      trim  = false;
   end
   
   if trim == true
      if ~isdatetime(t1); t1 = datetime(t1,'ConvertFrom','datenum'); end
      if ~isdatetime(t2); t2 = datetime(t2,'ConvertFrom','datenum'); end
      idx   = isbetween(time,t1,t2);
      ppt   = ppt(idx);
      flow  = flow(idx);
      time  = time(idx);
   end
   
   % Create figure
   f   = macfig;
   
   % Create plot
   yyaxis left;
   h1  = plot(time,flow); % datetick
   ax  = gca;
   
   % Set the remaining axes properties
   set(ax,'XMinorGrid','on','YMinorGrid','on');
   grid(ax,'on');
   
   % Keep current ylims to reset the labels after making space for ppt
   %     ylims = ylim
   % pick up on this , idea is to get the lims and labels then after
   % setting them *1.5, reset the ticks to the og ones
   
   ylim([ax.YLim(1),1.5*ax.YLim(2)]);
   
   % Create ylabel
   ylabel('Streamflow (mm)','Color',[0 0.447 0.741]);
   
   % Create second plot
   yyaxis right; % varargin{:} goes on bar if needed
   h2  = bar(time,ppt,'FaceColor',[0.85 0.325 0.098],'EdgeColor','none');
   
   % Create ylabel
   ylabel('Precipitation (cm d$^{-1}$)','Color',[0.85 0.325 0.098]);
   axis(ax,'ij');
   
   % return control to left axis
   yyaxis left
   
   % Set the remaining axes properties
   % set(ax,'Color','none','XAxisLocation','top','XTickLabel','');
   %     ylim([0,1.5*ax.YLim(2)]);
   
   % this should make the hyetograph and hydrograph not overlap
   
   % this shouldn't be needed with yyaxis functionality
   %   ax2.XTick = ax1.XTick;
   
   % Package output
   h.f     = f;
   h.ax1   = ax;
   h.ax2   = ax;
   h.h1    = h1;
   h.h2    = h2;
   
   
   % % this stuff was in the original version, shouldn't be needed with yyaxis
   % % make sure the top/bottom x-axes are linked
   %     linkaxes([ax1 ax2],'x');
   %     myaxistight([ax1 ax2],'x');
   
   % move the y lables
   % ypos1                   =   AX(1).YLabel.Position;
   % ypos2                   =   AX(2).YLabel.Position;
   % ypos1(2)                =   ypos1(2)/1.8;
   % ypos2(2)                =   ypos2(2)/1.8;
   % AX(1).YLabel.Position   =   ypos1;
   % AX(2).YLabel.Position   =   ypos2;
   
   
   
   % % % below here is the original function
   
   % [AX,H1,H2] = plotyy(dates,flow,dates,ppt,'plot','bar',varargin{:});
   %
   % % Set bar graph properties
   % set(get(AX(2),'Ylabel'),'String','Precipitation (mm)','FontSize',16, ...
   %         'Color',get(H2,'FaceColor'));
   % set(AX(2),'XTickLabel',[],'xaxislocation','top','YDir','reverse');
   %
   % % Set line graph properties
   % set(AX(1),'XTickLabel', []);
   % set(AX(1),'FontSize',16);
   % set(AX(1),'YColor','k');
   % set(get(AX(1),'Ylabel'),'String','Streamflow (mm)','FontSize',16,...
   %     'Color',get(H1,'Color'));
   % % Print Month and Year as Tick Label
   % % datetick(AX(1),'x','mmm yyyy')
   % % datetick('x','mm/yy');
   %
   % % Edit begin
   % % make sure the hyetograph and hydrograph don't overlap
   % % First make both axes 2x as long
   % AX(1).YLim(2)   =   2*AX(1).YLim(2);
   % AX(2).YLim(2)   =   2*AX(2).YLim(2);
   %
   % % ylim1       =   AX(1).YLim;
   % % ylim2       =   AX(2).YLim;
   % % ymax1       =   max(flow(:,1));
   % % ymax2       =   max(ppt(:,1));
   % % scale       =   ylim2(2)/ylim1(2); % ratio of ppt/flow axis
   % %
   % % if ymax2 > ymax1
   % % %     AX(2).YLim(2)   =   scale*(AX(2).YLim(2) + ymax1);
   % %     AX(2).YLim(2)   =   AX(2).YLim(2) + (scale*ymax1);
   % %     AX(1).YLim(2)   =   2*AX(1).YLim(2);
   % % end
   %
   % % Edit end - 2x each axis seems to work
   %
   % % format x tick lables
   % datetick('x','mmm-yyyy');
   % % make sure the top/bottom x-axes are linked
   % linkaxes([AX(2) AX(1)],'x');
   % myaxistight(AX,'x');
   % %
   % grid on
   % grid minor
   %
   % % move the y lables
   % ypos1                   =   AX(1).YLabel.Position;
   % ypos2                   =   AX(2).YLabel.Position;
   % ypos1(2)                =   ypos1(2)/1.8;
   % ypos2(2)                =   ypos2(2)/1.8;
   % AX(1).YLabel.Position   =   ypos1;
   % AX(2).YLabel.Position   =   ypos2;
   
end

