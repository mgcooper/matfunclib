% TLDR:
% The climits need to be computed berfore calling scatter if you want the
% colorbar linked across subplots. I was not able to find a way to update it
% after the fact. The idea was that I won't remember to get climits before hand
% and set clim(climits) in each subplot / after each call to scatter, but this
% will serve as a reminder.
% 
% Description:
% 
% climits are the color limits for the colormap. It is a two-element vector in
% which the first element specifies the data value to map to the first color in
% the colormap, and the second element specifies the data value to map to the
% last color in the colormap.    
% 
% subplot(1,2,1) and subplot(1,2,2) create two subplots in a 1x2 grid in the
% current figure. 
% 
% scatter(x, y, 100, cData(i,:), 'filled') creates scatter plots with filled
% markers. The color of each marker is determined by the corresponding element
% in cData(i,:).  
% 
% clim(climits) sets the colormap limits for the current axes. This ensures
% that the data values in cData are mapped to colors in the colormap using the
% same scale in both subplots.  
% 
% legend creates a legend for each subplot.
% 
% colorbar adds a colorbar to each subplot. The limits of the colorbar match the
% current colormap limits of the axes, which were set by clim(climits).  

% check this
% https://www.mathworks.com/matlabcentral/answers/245908-how-to-set-scatter-plot-colors-in-order-to-adjust-all-plots-to-a-same-reference

% revisit the geomask plot function i think it created a separate axis for the
% colorbar to avoid it getting int he way of the plot axis on resize
%% it might also be as simple as this

% Assuming H is your 1x2 BubbleChart object array and limits is your desired color limits

limits = [0 10]; % Replace with your own limits

H(1).Parent.CLim = limits;
H(2).Parent.CLim = limits;


%% with tiledlayout it should be easier to just create one colorbar

tcl = tiledlayout(3,4);
for i = 1:prod(tcl.GridSize)
    nexttile()
    [X,Y,Z] = peaks(2+i);
    contourf(X,Y,Z)
    clim([-7,6])  % Important!  Set the same color limits
end
cb = colorbar(); 
cb.Layout.Tile = 'east'; % Assign colorbar location

%% might also work to pass the axis to colrmap
load clown.mat
image(X)
load penny.mat
image(P)
figure(1)
hFig=gcf;
set(hFig, 'Position', [50 50 300 500]);
subplot(2,1,1)
image(X);
colormap(gca,'gray')
hcb1=colorbar;
subplot(2,1,2)
image(P);
colormap(gca,'jet')
hcb2=colorbar;

%% original example
% Initialize example data
x = rand(100, 1);
y = rand(100, 1);
cData1 = rand(100, 1) * 10; % color data for the first subplot
cData2 = rand(100, 1) * 100 + 50; % color data for the second subplot
legendNames = {'Plot 1', 'Plot 2'};

% Compute the global color limits
climits = [min([cData1(:); cData2(:)]), max([cData1(:); cData2(:)])];

%% Create the first figure without clims linked
figure

% First subplot
subplot(1,2,1)
scatter(x, y, 100, cData1, 'filled')
legend(legendNames{1},'location','ne')
colorbar

% Second subplot
subplot(1,2,2)
scatter(x, y, 100, cData2, 'filled')
legend(legendNames{2},'location','ne')
colorbar


%% Create the second figure with clims linked
figure

% First subplot
subplot(1,2,1)
scatter(x, y, 100, cData1, 'filled')
clim(climits); % Set the color limits of the current axes
legend(legendNames{1},'location','ne')
colorbar

% Second subplot
subplot(1,2,2)
scatter(x, y, 100, cData2, 'filled')
clim(climits); % Set the color limits of the current axes
legend(legendNames{2},'location','ne')
colorbar

%% set after the fact (doesn't work)
figure

% First subplot
subplot(1,2,1)
scatter(x, y, 100, cData1, 'filled')
legend(legendNames{1},'location','ne')
colorbar

% Second subplot
subplot(1,2,2)
scatter(x, y, 100, cData2, 'filled')
legend(legendNames{2},'location','ne')
colorbar


[C, climits] = setcolorbar("AutoColorLimits",true);

% Find all scatter objects in the current figure
scatters = findobj(gcf, 'Type', 'Scatter');

for n = 1:numel(scatters)
   scatters(n).CData = rescale(scatters(n).CData, climits(1), climits(2));
end


%% below here original inspiration
% climits = [min(dR(:)), max(dR(:))];
% 
% maxfig
% subplot(1,2,1)
% scatter(X(runpoints), Y(runpoints), 100, dR(1,:), 'filled')
% legend(testruns(2),'location','ne')
% cb1 = colorbar;
% set(cb1, 'Limits', climits)
% clim(climits);
% 
% subplot(1,2,2)
% scatter(X(runpoints), Y(runpoints), 100, dR(2,:), 'filled')
% legend(testruns(3),'location','ne')
% cb2 = colorbar;
% set(cb2, 'Limits', climits)
% clim(climits);
% 
% %%
% 
% maxfig
% subplot(1,2,1)
% scatter(X(runpoints), Y(runpoints), 100, dR(1,:), 'filled')
% legend(testruns(2),'location','ne')
% cb1 = colorbar;
% [cmin(1), cmax(1)] = clim;
% 
% subplot(1,2,2)
% scatter(X(runpoints), Y(runpoints), 100, dR(2,:), 'filled')
% legend(testruns(3),'location','ne')
% cb2 = colorbar;
% [cmin(2), cmax(2)] = clim;
% 
% set(cb1, 'Limits', [min(cmin(:)) max(cmax(:))])
% set(cb2, 'Limits', [min(cmin(:)) max(cmax(:))])
% clim([min(cmin(:)) max(cmax(:))])
% 
% %%
% 
% maxfig
% subplot(1,2,1)
% scatter(X(runpoints), Y(runpoints), 100, dR(1,:), 'filled')
% clim(climits); 
% legend(testruns(2),'location','ne')
% colorbar
% 
% subplot(1,2,2)
% scatter(X(runpoints), Y(runpoints), 100, dR(2,:), 'filled')
% clim(climits);
% legend(testruns(3),'location','ne')
% colorbar