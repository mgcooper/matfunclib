function varargout = plotting_tricks(varargin)
%PLOTTING_TRICKS plotting tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%%


% % doesn't work but maybe subplot could be edited 
% % See if this works:
% f = figure;
% ax = gca;
% subplot(f,4,4,1:16,ax); hold on;
% plot(1:10,1:10)
% subplot(4,4,4,ax)% to put an inset in position 4



% see deselectall or deselectfig to get rid of the annoying selection box on a
% figure

% investigate the 'NextPlot' add fucntionality:
figure; 
plot(lambda,halflengthsnow);
xlabel('wavelength (nm)');
ylabel('Half-Length of Snow (m)');

xticklabels = ax.XTickLabel;

%
Axes1H = axes('NextPlot', 'add');
Axes1H = axes('NextPlot', 'add', 'YTickLabel', {}, 'XTickLabel', {}, ...
              'XColor', [1,1,1], 'YColor', [1,1,1], ...
              'Color', rgb('light grey'), ...
              'Box', 'on', 'XGrid', 'on', 'YGrid', 'on', ...
              'LineWidth',2,'GridColor',rgb('white'));
           
           
% =====================================================================
% use getkey to get keyboard input
% =====================================================================

% example from BFRA_getdQdt
   if opts.pausetosave == true
      disp('press s to save the figure, p to pause code, or any other key to continue');
      ch = getkey();
      if ch==115
         fname = ['dqdt_' opts.station '_' datenum2yyyyMMMdd(T) '.png'];
         exportgraphics(gcf,[opts.figs.dqdt fname],'Resolution',300);
      elseif ch==112
         pause;
      end
         
   end
   
% =====================================================================
% alternatives to standard latex font
% =====================================================================

legend({'$\mathrm{text here}$','$\mathsf{text here}$','$\mathit{text here}$'});
figformat

title('$\mathsf{text_{sub}\, here}$')

title('$\mathsf{\alpha_{sub}\, here}$')


% =====================================================================
% check if figure exists
% =====================================================================
g = groot;
if isempty(g.Children)
  f = figure;
else
  f = gcf;
end
    
% =====================================================================
%  get monitor
% =====================================================================

s    = get(0, 'MonitorPositions'); s = s(2,:);
f(2) = figure('Position', [s(1) s(2) s(3) s(4)]); tiledlayout('flow');
    
% =====================================================================
%  geo axes
% =====================================================================

gx = geoaxes

gx.LatitudeAxis.TickLabelInterpreter  = 'Latex';
gx.LongitudeAxis.TickLabelInterpreter = 'Latex';


% =====================================================================
%  CHANGE LEGEND MARKERS, LINE WIDTH, ETC
% =====================================================================


[hl,icons,plots,txt] = legend([h2 h1],legtext,'FontSize',12,'Location','east',  ...
                        'Interpreter','latex');

h = figformat;

% thicken the lines
icons(3).LineWidth  = 2.5;
icons(5).LineWidth  = 2.5;

% shorten the lines
icons(3).XData      = 2/3*icons(3).XData;
icons(5).XData      = 2/3*icons(5).XData;

% move the text
lpos1               = icons(1).Position;
lpos2               = icons(2).Position;
icons(1).Position   = [2/3*lpos1(1) lpos1(2) 0];
icons(2).Position   = [2/3*lpos2(1) lpos2(2) 0];

% resize the box
hl.ItemTokenSize(1) = 10;

% move the box
hl.Position(2)  = 0.95*hl.Position(2);


h.mainAxis.XAxis.TickLabels = compose('%g',h.mainAxis.XAxis.TickValues);
h.mainAxis.YAxis.TickLabels = round(h.mainAxis.YAxis.TickValues-1,1);
h.backgroundAxis.Position   = h.mainAxis.Position;


% =====================================================================
%  INHERET PROPERTIES
% =====================================================================

% NOTE: this didn't work, and I found a solution in figformat, but could be
% good to see how getting the children works in this case and copyobj

figure; 
myscatter(log(alla),log(atest)); 
xlabel('log($a$)');
ylabel('log($a$) = 10-15$*b$');
ax1 = gca;
ff = figformat;
ax2 = gca;
ax2a = ff.mainAxis;
ax2b = ff.backgroundAxis;
addOnetoOne;
ax3 = gca;
ax1Children     = ax1.Children;
ax2Children     = ax2.Children;
ax2aChildren    = ax2a.Children;
ax2bChildren    = ax2b.Children;
ax3Children     = ax3.Children;
fChildren       = ff.figure.Children;
copyobj(fChildren, gcf)
% Copy all ax1 objects to axis 2
copyobj(ax2Children, ax3)
copyobj(ax2aChildren, ax3)
copyobj(ax2bChildren, ax3)



% publication quality figures, from matlab recipes for earth sciences:
% http://mres.uni-potsdam.de/index.php/2017/02/09/create-publishable-graphics-with-matlab/

% noting here, this could be useful to know about
drawnow

% also, 
el = addlistener(hSource,EventName,callback)
el = addlistener(hSource,PropertyName,EventName,callback)

% ========================================================================
% EXAMPLE OF OVERLOADED PLOT, ALSO USEFUL ANCESTOR EXAMPLE
% ========================================================================

% % function varargout = plot(varargin)
% %     plotH = builtin('plot',varargin{:});
% %     axH   = ancestor(plotH(1),'Axes'); % plotH can be an array if inputs to 'plot' are matrices
% %     if ~ishold(axH), axH.Box = get(groot,'DefaultAxesBox'); end
% %     if nargout, varargout{1} = plotH; end
% % end

% % If you overload the builtin "plot", MATLAB will issue warnings. You can turn those off using:
% warning('off','MATLAB:dispatcher:nameConflict')

% % *you can make the builtin plot honour the TickDir default using: 
% set(groot,'DefaultAxesTickDirMode','manual');

% ========================================================================
% COLORBARS
% ========================================================================

% Change colorbar width

c = colorbar;
axpos = get(gca,'Position');
cpos = get(c,'Position');
cpos(3) = 0.5*cpos(3);
set(c,'Position',cpos);
set(gca,'Position',axpos);

% put a title on a colorbar
c = narrowcolorbar(.5);
set(get(c,'title'),'string','km^3')
					
% move the colorbar title location. Unfortunately, there is no 'Location' property for the title, so must use 'Position'
pos = c.Label.Position;

% pos(1) is left/right, pos(2) is up/down. 
c.Label.Position 	= 	[pos(1)/ratio pos(2)+delta];

% default location units are 'Data' i.e. the data plotted in the colorbar. Could change to 'normalized'
c.Label.Units 		= 	'normalized';

% make plot background white
set(gcf,'Color','w')
% make plot background transparent
set(gca,'Color','none'); % sets axes background
% then use export_fig with -transparent option
export_fig test.png -transparent

% link colorbar across subplots

subplot(1,3,1)
mapshow(Z,R)
[cmin cmax] = caxis;

subplot(1,3,2)
mapshow(Z2,R2)
caxis([cmin cmax])

subplot(1,3,3)
mapshow(Z3,R3)
caxis([cmin cmax])


% FOR COPYING INTO SCRIPTS:
[cmin cmax] = caxis;
caxis([cmin cmax])


% resize the image after adding a colorbar


% ========================================================================
% LATEX
% ========================================================================

% function compose can be used to format text, labels, etc. I cannot recall
% which code, but I used it to add percent signs, search Walter Robinson's
% answers to find where he suggested it

% if you don't want 'tex' or 'latex' you have to enclose the text in {}:
plot(1:10,1:10);
xlabel('{\it B}, [units]') % this works
% xlabel('{\it B}, [units]','Interpreter','tex') % it's equivalent to this
% xlabel('\it {B}, [units]') % this doesnt work
% xlabel('$\it {B}$, [units]','Interpreter','latex') % this requires latex

% from fdcurve, add percent signs to ticklabels with latex :
ax.XAxis.TickLabels = compose('$%g\\%%$',ax.XAxis.TickValues);

% or:
ax.XAxis.TickLabels = cellstr(num2str(ax.XAxis.TickValues','$%g\\%%$'))

% the key thing is the double escape character needed with any sprintf type
% format spec, see also bfra_QtauString, and the double percent sign whihc
% escapes the percent sign


% ========================================================================
% SCIENTIFIC NOTATION IN LABELS / LEGENDS/ ETC
% ========================================================================

% from bfra_check-events
ab      = [1e-9;2.13];  % dummy
aexp    = floor(log10(ab(1)));
abase   = ab(1)*10^abs(aexp);
abstr   = sprintf('$-dQ/dt = %.fe^{%.f}Q^{%.2f}$',abase,aexp,ab(2));

x       = linspace(1e6,4e6,100);
y       = ab(1).*x.^ab(2);
figure; loglog(x,y,'-o'); hold on;
legend(abstr,'Interpreter','latex')

% ========================================================================
% TICK LABELS
% ========================================================================

rotateXLabels

% ========================================================================
% COMPOSE TICK LABELS
% ========================================================================

% COMPOSE yticklabels
% ax.YAxis.TickLabels = compose('%g',ax.YAxis.TickValues);


% if the ifgure position or axis position isn't updating correctly or other
% things are acting weird, add a 'pause(1)' statemtn and it might fix it.
% this is the thing i ran into where highlighting and runnign one part and
% then highlighting the next part works, but running as a script or
% function it doesn't update correctly. see mycolorbar

% this was saved as 'log_meshplot_discrete_colorbar'
% after this is code from /CODE/tips_tricks folder that was saved as
% 'log_minor_tick_labels'

% idea: pin the colorbar to the right side of the axis e.g. like how
% legends can be pinned to one corner, so the colorbar has the same size as
% the box

clean

% racmo is 1000 km resolution, size is 2700 x 1496 = 4039200
load('Rracmo.mat')

% calculate the number of bytes per variable per timestep
sf                  =   1; % scale factor relative to 1000 m
nvars               =   20;
nyears              =   30;
ndigits             =   4; % digits per variable
timestepinhours     =   3;
ncells              =   Rracmo.RasterSize(1)*Rracmo.RasterSize(2);
ncells              =   (sf^2)*ncells;
ntimesteps          =   (24/timestepinhours)*365*nyears; % 3 hourly for 30 years
nbytes              =   nvars*ndigits*ncells*ntimesteps;
nGBs                =   nbytes./(10^9);
nTBs                =   nGBs/1000;

% that yields 16 TB. It will scale linearly with nyears and exponentially
% with sf. assume 4 digits per variable, although a few could get by with
% less

%%
clean
load('Rracmo.mat')
vars                =   {'tair','rh','wspd','wdir','swd','swu','lwd','lwu', ...
                            'shf','lhf','ghf','albedo','runoff','subl', ...
                            'melt','sprec','rprec','sdrift','refreeze'};                        
sf                  =   1:1:10; % scale factor relative to 1000 m
nvars               =   length(vars);
ndigits             =   4; % digits per variable
ncells              =   Rracmo.RasterSize(1)*Rracmo.RasterSize(2);
nyears              =   1:1:30;
ntimesteps          =   3*365.*nyears; % 3 hourly for 30 years
nbytes              =   (sf.^2).*ncells.*nvars.*ndigits.*ntimesteps';
nGBs                =   nbytes./(10^9);
nTBs                =   (nGBs./1000)';

%%
X                   =   nyears;
Y                   =   log10(1000./sf);
Z                   =   log10(nTBs);

% make the figure
f                   =   figure;
h                   =   mesh(X,Y,Z,'FaceColor','flat'); ax = gca; view(2);

% set the tick marks
yticks              =   fliplr(1000./sf);
yticklabels         =   num2str((roundn(yticks,0))');
ax.YTick            =   log10(yticks);
ax.YTickLabel       =   yticklabels;
ax.XMinorGrid       =   'on';
ax.YMinorGrid       =   'on';
ax.XLabel.String    =   '# of simulation years';
ax.YLabel.String    =   'horizontal resolution (m)';

% make the colorbar
c                   =   colorbar;
cmap                =   colormap(parula(20));
minval              =   min(Z(:));
maxval              =   max(Z(:));
c.Ticks             =   linspace(minval,maxval,length(cmap)+1);
c.TickLength        =   0.045; % c.Position(3);
cticklabels         =   c.TickLabels;
newcticklabels      =   cticklabels(1:5:end);
tickinds            =   1:5:length(cticklabels);
for n = 1:length(cticklabels)
    if any(n==tickinds)
        cticklabel      =   roundn(10^str2num(cticklabels{n}),0);
        c.TickLabels{n} =   cticklabel;
    else
        c.TickLabels{n}     =   '';
    end
end
c.Label.String      =   '# of TBs';

% cticklabels         =   10.^ cell2mat(cticklabels);
% c.TickLabels        =   c.TickLabels(1:5:end);
% cmap                =   colormap;



plot(1000./sf,nTBs); xlabel('Spatial Resolution (m)'); ylabel('TB');
set(gca,'YScale','log','YLim',[1 1000],'YTick',[1;5;10;50;100;500;1000], ...
    'YMinorGrid','on','XMinorGrid','on','YAxisLocation','right')


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% log_minor_tick_labels
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% when making the Kext regressions plot I wanted to control the y minor
% tick values which I figured out but then I discovered I cannot control
% the minor tick labels, below is a method I found to label minor ticks on
% a log plot:

% from:
% https://www.mathworks.com/matlabcentral/answers/17559-labeling-minor-tick-marks-in-plots

figure
y = [0.32,0.4,0.5,0.8,1,1.5,2,4,4.5,9.9,10.5];
semilogy(y);
set(gca,'yMinorTick','off')

%%
min_y                   = min(y);
max_y                   = max(y);
most_sig_position_min   = 10^floor((log10(min_y)));
most_sig_digit_min      = floor(min_y / most_sig_position_min);
min_yaxis               = most_sig_digit_min * most_sig_position_min;
most_sig_position_max   = 10^floor((log10(max_y)));
most_sig_digit_max      = ceil(max_y / most_sig_position_max);
max_yaxis               = most_sig_digit_max * most_sig_position_max;
p(1)                    = ceil(log10(min_yaxis));
p(2)                    = ceil(log10(max_yaxis));
ticks = [];
for k=p(1):p(2)
    if k==p(1)
        ticks = [ticks min_yaxis:10^(k-1):10^k];
    elseif k==p(2)
        ticks = [ticks 10^(k-1)+10^(k-1):10^(k-1):max_yaxis];
    else
        ticks = [ticks 10^(k-1)+10^(k-1):10^(k-1):10^k];
    end
end
set(gca,'ytick',ticks())
axis([-Inf Inf min_yaxis max_yaxis])

%% below is my attemp to modify it for log base e. I am sure I can fix it but for now it is broken
y = [];
for n = 1:length(h)
    ydata = h(n).YData;
    y = [y ydata];
end

min_y = min(y);
max_y = max(y);
most_sig_position_min = exp(floor((log(min_y))));
most_sig_digit_min = floor(min_y / most_sig_position_min);
min_yaxis = most_sig_digit_min * most_sig_position_min;
most_sig_position_max = exp(floor((log(max_y))));
most_sig_digit_max = ceil(max_y / most_sig_position_max);
max_yaxis = most_sig_digit_max * most_sig_position_max;
p(1) = ceil(log(min_yaxis));
p(2) = ceil(log(max_yaxis));
ticks = [];
for k=p(1):p(2)
    if k==p(1)
        ticks = [ticks min_yaxis:exp(k-1):exp(k)];
    elseif k==p(2)
        ticks = [ticks exp(k-1)+exp(k-1):exp(k-1):max_yaxis];
    else
        ticks = [ticks exp(k-1)+exp(k-1):exp(k-1):exp(k)];
    end
end
set(gca,'ytick',ticks())
% axis([-Inf Inf min_yaxis max_yaxis])


