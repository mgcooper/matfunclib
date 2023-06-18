function H = stackedBarPlot(stackedGroupData,groupLabels,opts)
%STACKEDBARPLOT create stacked bar plot for grouped data with labels
%
%  H = STACKEDBARPLOT(stackedData) description
%  H = STACKEDBARPLOT(H,'flag1') description
%  H = STACKEDBARPLOT(H,'flag2') description
%  H = STACKEDBARPLOT(___,'options.name1',options.value1,'options.name2',options.value2) description
%        The default flag is 'plot'.
%
% Inputs
%  stackedGroupData is a 3D matrix with groups down rows, within-group data
%  across columns, and within-group stacks (categories) across pages, e.g.
%  stackedGroupData(i, j, k) => (Group, Data, StackElement))
%
% groupLabels is a CELLSTR (i.e., { 'a', 1 , 20, 'because' };)
%
% Example
%
% Matt Cooper, 22-Mar-2023, https://github.com/mgcooper
%
% See also

%-------------------------------------------------------------------------------
% input parsing
%-------------------------------------------------------------------------------

arguments
   stackedGroupData (:,:,:) double
   groupLabels (:,:) cell = {''}
   opts.?matlab.graphics.chart.primitive.Bar
end

%-------------------------------------------------------------------------------

% % to add a second y-axis
% % if Y1 has just one row, add dummy zeros for correct plotting
% inputDataIsSingle = false;
% if size(Y1, 1) == 1
%    inputDataIsSingle = true;
%    Y1(2,:,:) = zeros(size(Y1,2), size(Y1,3));
%    Y2(2,:,:) = zeros(size(Y2,2), size(Y2,3));
% end

% % to put the label somewhere else
% % Labels for individual bars are on the top b/c the Y coordinate for that text
% % is set to the sum of all the columns. To label underneath the bars (and just
% % under the line marking the x-axis), change the added code starting at line 36
% % to
%
% for j=1:NumGroupsPerAxis
%    text(groupDrawPos(j),0,...
%    barLabels{i},'VerticalAlignment','cap',...
%    'HorizontalAlignment','center');
% end

%% Original function

% Data model:           Plot:
%    _______
%   /      /|          ___
%  /      / | cat 3 -> | |
% /______/  |          |_|  __
% |cat 3 |  |          | |_|_|
% |cat 2 |  / cat 1 -> | |_|_|
% |cat 1 | /           |_|_| |
% |______|/   cat 1 -> | | | |
%                      Group 1
%                    
% Each category (cat) is a stack element, 

% NOTE in the original function, 'groups' are along the x-axis, but in my
% application to water demand I was thinking of groups as being different data
% sets at the same timestep, so DRBC demand would be one stacked bar, and GCAM
% demand another bar, and together they make a group, which is consistent with
% the original function but confusing b/c the x-ticks are still years, not
% groups. Also I changed terminology from 'stacks' to 'cats', so each stack has
% a set of categories, and each group has a set of stacks. 

% EITHER WAY I BROKE IT ... see plotBarStackGroupsDualYaxis, plotBarStackGroups,
% and example_stackedBarPlot to fix it

NumCatsPerStack = size(stackedGroupData, 1);
NumStacksPerGroup = size(stackedGroupData, 2);
NumGroups = size(stackedGroupData, 3);



% init the output, not sure about second dimension
h = gobjects(NumCatsPerStack,NumGroups);

% Count off the number of bins
groupBins = 1:NumStacksPerGroup;
MaxGroupWidth = 0.65; % Fraction of 1. If 1, then we have all bars in groups touching
groupOffset = MaxGroupWidth/NumCatsPerStack;

figure; hold on;
for n=1:NumCatsPerStack
   
   Y = squeeze(stackedGroupData(:,n,:));

   % Center the bars:
   internalPosCount = n - ((NumCatsPerStack+1) / 2);

   % Offset the group draw positions:
   groupDrawPos = (internalPosCount)* groupOffset + groupBins;

   h(n,:) = bar(Y, 'stack');
   set(h(n,:),'BarWidth',groupOffset);
   set(h(n,:),'XData',groupDrawPos);
end

hold off;
set(gca,'XTickMode','manual');
set(gca,'XTick',1:NumStacksPerGroup);
set(gca,'XTickLabelMode','manual');
set(gca,'XTickLabel',groupLabels);
end