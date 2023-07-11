function varargout = barchartcats(T,ydatavar,xgroupvar,cgroupvar,method, ...
   BarChartOpts,CustomOpts)
%BARCHARTCATS bar chart by groups along x-axis and by color within groups
%
% Description
%
% This function creates a bar chart of the data grouped by specified categories.
%
% Syntax
%
% h = barchartcats(T, ydatavar) creates a bar chart, for column ydatavar in table
% T. If T.(ydatavar) is a vector, then barchart creates a single bar chart. In
% this mode, BARCHARTCATS behaves exactly like BOXCHART(ydata) where ydata =
% T.(ydatavar).
%
% h = barchartcats(T, ydatavar, xgroupvar) groups the data in the vector
% T.(ydatavar) according to the unique values in T.(xgroupvar) and plots each
% group of data as a separate bar chart. xgroupdata determines the position of
% each bar chart along the x-axis. ydata must be a vector, and xgroupdata must
% have the same length as ydata.
%
% creates a bar chart, or bar plot, for column
% ydatavar in table T. If T.(ydatavar) is a vector, then barchart creates a single
% bar chart. In this mode, BARCHARTCATS behaves exactly like BOXCHART(ydata)
% where ydata = T.(ydatavar).
%
% h = barchartcats(T, ydatavar, xgroupvar, cgroupvar, "XGroupMembers",
%  xgroupmembers, "CGroupMembers", cgroupmembers) uses color to differentiate
% between bar charts. The software groups the data in the vector ydata according
% to the unique value combinations in xgroupdata (if specified) and cgroupdata,
% and plots each group of data as a separate bar chart. The vector cgroupdata
% then determines the color of each bar chart. ydata must be a vector, and
% cgroupdata must have the same length as ydata. Specify the 'GroupByColor'
% name-value pair argument after any of the input argument combinations in the
% previous syntaxes.
%
% h = barchartcats(_, Name, Value) specifies additional chart options using one
% or more name-value pair arguments. For a list of properties, see BarChart
% Properties. 
%
% Input Arguments
%
% T: A table containing the data to be plotted.
% ydatavar: The name of the variable in the table T that contains the data values
% for the bar chart.
% xgroupvar: The name of the categorical variable in the table T used to define
% groups along the x-axis.
% cgroupvar: The name of the categorical variable in the table T used to define
% groups for the colors of the bares.
% method: the method used in the call to groupsummary to compute the values
% plotted as bars. The default method is 'mean'. For 'mean', the standard
% deviation is also computed in the call to groupsummary to support the addition
% of whiskers to the bars. If 'median' is passed in as the method, the whiskers
% represent the interquartile range. Note: whiskers are not currently supported.
% xgroupuse: A cell array of categories to be used for the x-axis grouping.
% cgroupuse: A cell array of categories to be used for the color grouping.
% varargin: Additional optional arguments for the barchart function.
%
% Output Argument
%
% H: A handle to the created bar chart.
%
% Example
%
% This example reads data from a CSV file into a table T, and plots a bar chart
% of the Value variable, grouped by the CategoryX and CategoryC variables. The
% x-axis grouping includes categories 'Cat1', 'Cat2', and 'Cat3', while the
% color grouping includes categories 'Group1' and 'Group2'.
%
% T = readtable('data.csv');
% ydatavar = 'Value';
% xgroupvar = 'CategoryX';
% cgroupvar = 'CategoryC';
% xgroupuse = {'Cat1', 'Cat2', 'Cat3'};
% cgroupuse = {'Group1', 'Group2'};
%
% h = barchartcats(T, ydatavar, xgroupvar, cgroupvar, xgroupuse, cgroupuse);
%
% Use optional arguments:
%
% h = barchartcats(T, ydatavar, xgroupvar, cgroupvar, xgroupuse, cgroupuse, ...
%    'Notch','on','MarkerStyle','none');
%
% Matt Cooper, 29-Nov-2022, https://github.com/mgcooper
%
% See also reordergroups, reordercats, barchart

% BSD 3-Clause License
%
% Copyright (c) 2023, Matthew Guy Cooper (mgcooper)
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% Note, the columns need to be categorical, but the 'x/cgroupvar' and
% 'xgroupuse/c' inputs can be strings/chars/cellstr or categorical. Specifying
% 'string' in the arguments block performs an implicit conversion to string, and
% ismember('someCategoricalVariable','someStringVariable') works but iff the
% string is scalar (or cell array of chars), so the approach taken here is to
% convert to string. In a few places, attention is needed to convert to string
% if non-scalar string/categorical comparisons are made.

%---------------------- parse arguments
arguments
   T table
   ydatavar (1,1) string { mustBeNonempty(ydatavar) }
   xgroupvar (1,1) string { mustBeNonempty(xgroupvar) }
   cgroupvar (1,1) string = "none"
   method (:,1) string = "mean"
   BarChartOpts.?matlab.graphics.chart.primitive.Bar
   CustomOpts.SortBy (1,1) string {mustBeMember(CustomOpts.SortBy,["ascend","descend","none"])} = "none"
   % SortGroupMembers are members of cgroupvar to be used for computing the
   % sorting order of the xgroups. For example, if there are five xgroup members
   % i.e., five unique values of T.(xgroupvar), and three cgroup members, i.e.,
   % three unique values of T.(cgroupvar), teh default behavior of "ascend" is
   % to compute the average value of the three cgroup bars in each xgroup and
   % sort by those average values. If instead you want to sort by a particular
   % cgroup member, specify them using CustomOpts.SortGroupMembers.
   CustomOpts.SortGroupMembers (:,1) string = "all"
   CustomOpts.ShadeGroups (1,1) logical = true
   CustomOpts.Parent (1,1) {mustBeA(CustomOpts.Parent, "matlab.graphics.axis.AbstractAxes")} = gca
   CustomOpts.PlotError (1,1) logical = true
   CustomOpts.MergeGroups (:,1) = []
   CustomOpts.XGroupOrder (:,1) string = "none"
   CustomOpts.XGroupMembers (:,1) string = "none"
   CustomOpts.CGroupMembers (:,1) string = "none"
   % CustomOpts.GroupSelect (:,1) string = "none"
   CustomOpts.SelectVars (:,1) string = "none"
   CustomOpts.LegendText (:,1) string = ""
   CustomOpts.LegendOrientation (1, 1) string = "vertical"
   % CustomOpts.PlotMeans (1,1) logical = true
   % CustomOpts.ConnectMeans (1,1) logical = false
end

% % Override default BoxChart settings
% ResetFields = {'JitterOutliers','Notch'};
% ResetValues = {true,'on'};
% for n = 1:numel(ResetFields)
%    if ~ismember(ResetFields{n},fieldnames(BarChartOpts))
%       BarChartOpts.(ResetFields{n}) = ResetValues{n};
%    end
% end
varargs = namedargs2cell(BarChartOpts);
%--------------------------------------


%---------------------- validate inputs

xgroupuse = CustomOpts.XGroupMembers;
cgroupuse = CustomOpts.CGroupMembers;
% groupselect = CustomOpts.GroupSelect;
% selectvars = CustomOpts.SelectVars;

% Require at least one grouping variable
if cgroupvar == "none" && xgroupvar == "none"
   error('No xgroupvar or cgroupvar provided, try barchart(T.(ydatavar))')
end

% Confirm ydatavar and xgroupvar are valid variables of table T
validatestring(ydatavar,T.Properties.VariableNames,mfilename,'ydatavar',2);
validatestring(xgroupvar,T.Properties.VariableNames,mfilename,'xgroupvar',3);

% Downselect the table if requested
if CustomOpts.SelectVars ~= "none"
   T = groupselect(T, T.Properties.VariableNames, CustomOpts.SelectVars);
end

% Confirm each member of xgroupuse/c are members of T.(x/cgroupvars)
if xgroupuse == "none" % use all unique values in xgroupvar
   xgroupuse = string(unique(T.(xgroupvar)));
else
   arrayfun(@(n) validatestring(xgroupuse(n), ...
      string(unique(T.(xgroupvar))),mfilename,'xgroupuse',5), 1:numel(xgroupuse));
end
inxgroup = ismember(string(T.(xgroupvar)),xgroupuse);

% cgroupvar is optional so it requires additional logic
if cgroupvar == "none"
   % Deal with the case where
   incgroup = true(height(T),1);
else
   validatestring(cgroupvar,T.Properties.VariableNames,mfilename,'cgroupvar',4);

   if cgroupuse == "none" % use all unique values in cgroupvar
      cgroupuse = string(unique(T.(cgroupvar)));
   else
      arrayfun(@(n) validatestring(cgroupuse(n), ...
         string(unique(T.(cgroupvar))),mfilename,'cgroupuse',6), 1:numel(cgroupuse));
   end
   incgroup = ismember(string(T.(cgroupvar)),cgroupuse);
end

% If xgroupvar/cgroupvar are not categorical, try to convert them
try T.(xgroupvar) = categorical(T.(xgroupvar)); catch; end
try T.(cgroupvar) = categorical(T.(cgroupvar)); catch; end

%--------------------------------------

%---------------------- main function

% barchartcats appears to work fine with repeated calls, but that might change
% if the xdata is found and used to plot on top
% hold off % repeated calls create problems

% creating a figure means it is difficult to put into subplots, so I added
% "Parent" option
% figure;

% Subset the categorical variable columns
Tcats = T(:,vartype('categorical'));

% Original method, assumed usegroupc and xgroupuse were required args, but
% works now that input checks handle the case where they are not given
% iplot = ismember(string(T.(cgroupvar)),cgroupuse) & ...
%    ismember(string(T.(xgroupvar)),xgroupuse);

iplot = incgroup & inxgroup;

% Keep the rows that are in usexgroupvars or usecgroupvars
Tplot = T(iplot,:);

% Remove rows that are not in xgroupuse
allcats = categories(Tcats.(xgroupvar));
badcats = allcats(~ismember(allcats,xgroupuse));
Tplot.(xgroupvar) = removecats(Tplot.(xgroupvar),badcats);

% Remove rows that are not in cgroupuse
if cgroupvar ~= "none"
   allcats = categories(Tcats.(cgroupvar));
   badcats = allcats(~ismember(allcats,cgroupuse));
   Tplot.(cgroupvar) = removecats(Tplot.(cgroupvar),badcats);
end

% Try to convert YData to double if it is categorical
if iscategorical(Tplot.(ydatavar))
   try
      Tplot.(ydatavar) = cat2double(Tplot.(ydatavar));
   catch
      % let the built-in error catching do the work.
   end
end

% Assign the data to plot
XData = Tplot.(xgroupvar);
YData = Tplot.(ydatavar);
try
   CData = Tplot.(cgroupvar);
catch
   CData = true(size(YData));
end

% Above here identical to boxchartcats
% % % % % % % % % % % % %

if istable(Tplot)
   [XData, YData, ~] = summarizeTableGroups(Tplot, ydatavar, xgroupvar, cgroupvar, method);
else
   [XData, YData, ~] = summarizeMatrixGroups(Tplot, ydatavar, xgroupvar, cgroupvar, method);
end

% I think I need to adapt the boxchartxdata method to plot the error whiskers

% Note: right now group merging and group sorting are incompatible, e.g. if
% merging is requested, then we effectively have new xgroups, so we don't know
% how to use SortGroupMembers. It likely only matters for default case right
% now, when SortGroupMembers is not specified, the firrst approach I developed
% used all the xgroups, but if they're merged, that won't work, so instead, I
% might need to find the indices and use them instead of SortGroupMembers, 

% Need to add validation to ensure SortGroupMembers are members of CData

% Custom group merging
if isempty(CustomOpts.MergeGroups)
   % Find the columns to use for computing the sort
   if CustomOpts.SortGroupMembers == "all"
      CustomOpts.SortGroupMembers = string(unique(CData));
   end
   CustomOpts.SortColumns = ismember(string(unique(CData)), CustomOpts.SortGroupMembers);
else
   [YData, CustomOpts] = mergeGroupColumns(CustomOpts, YData, CData);
end

% Custom ordering along x-axis
[XData, YData] = reorderGroups(CustomOpts, XData, YData);


% Create the figure
[H, L] = createCategoricalBarChart(XData, YData, CData, ydatavar, CustomOpts, varargs);

hold off
switch nargout
   case 1
      varargout{1} = H;
   case 2
      varargout{1} = H;
      varargout{2} = L;
end

end


function [XData, YData, EData] = summarizeTableGroups(T, ydatavar, ...
   xgroupvar, cgroupvar, method);
%SUMMARIZETABLEGROUPS

   % cgroupvar complicates this when it is "none" adn I don't think we need
   % it anyway, in boxchartcats I set CData to a logical the same size as
   % XData which I think is a hack to get boxchart to act right
   % G = groupsummary(Tplot,xgroupvar, ["mean", "std"], ydatavar);
   % NEVERMIND = we do need cgroupvar, it conrols how groupsummary returns
   % the groups which then implicitly gets bar to act right
   
   if strcmp(method,'mean')
      G = groupsummary(T,[cgroupvar xgroupvar], ["mean", "std"], ydatavar);
      XData = G.(xgroupvar);
      YData = G.("mean_" + ydatavar);
      EData = G.("std_" + ydatavar);
   elseif strcmp(method,'median')
      G = groupsummary(T,[cgroupvar xgroupvar], ["median", @iqr], ydatavar);
      XData = G.(xgroupvar);
      YData = G.("median_" + ydatavar);
      EData = G.("std_" + ydatavar);
   end
   
   % Each column of Y needs to correspond to a group of bars (each bar in a group
   % is a different color, each group is a different x-tick)
   % XData = reshape(XData, [], numel(xgroupuse));
   XData = unique(XData);
   YData = reshape(YData, numel(XData), []);
   EData = reshape(EData, numel(XData), []);

end


function [XData, YData, EData] = summarizeMatrixGroups(T, YData, XData, CData, method)
%

   % NOTE: Not functional, I don't think the calling syntax to groupsummary is
   % right, I think YData is not needed or needs to take the place of T.
   
   if strcmp(method,'mean')
      % [mu, uv, uc] = groupsummary(YData, [XData CData], ["mean", "std"]);
      G = groupsummary(T, [XData CData], ["mean", "std"], YData);
   elseif strcmp(method,'median')
      % [mu, uv, uc] = groupsummary(YData, [XData CData], {"median", @iqr});
      G = groupsummary(T, [XData CData], {"median", @iqr}, YData);
   end

end

function [NewYData, CustomOpts] = mergeGroupColumns(CustomOpts, YData, CData)
%MERGEGROUPCOLUMNS

   % mergegroups is the YData column indices to merge, so the new YData needs to
   % contain the unmerged groups and the merged groups. The new YData are
   % ordered with the merged groups in the position of the smallest index for
   % that group and the unmerged groups in their original position relative to
   % the smallest index of the merged groups.
   mergegroups = CustomOpts.MergeGroups;
   dontmerge = setdiff(1:size(YData, 2), horzcat(mergegroups{:}));
   NewYData = nan(size(YData));
   NewCGroups = string(unique(CData));
   NewYData(:, dontmerge) = YData(:, dontmerge);
   for n = 1:numel(mergegroups)
      NewYData(:, min(mergegroups{n})) = mean(YData(:, mergegroups{n}), 2);
      NewCGroups(min(mergegroups{n})) = strjoin(NewCGroups(mergegroups{n}));
      NewCGroups(max(mergegroups{n})) = missing;
   end
   NewYData = NewYData(:, ~all(isnan(NewYData)));
   NewCGroups = NewCGroups(~ismissing(NewCGroups));

   % Also need to adjust CustomOpts.SortGroupMembers
   % Find the columns to use for computing the sort
   if CustomOpts.SortGroupMembers == "all"
      % Not sure we need to set the members, but if so, when merging, they lose
      % their meaning
      CustomOpts.SortGroupMembers = NewCGroups;
      CustomOpts.SortColumns = 1:size(NewYData, 2);
      % sortgroups = string(unique(CData));
   else
      % Find the members of mergegroups that are also in SortGroup? 
      NewSortGroups = NewCGroups;
      for n = 1:numel(NewCGroups)
         tf = ~any(ismember(CustomOpts.SortGroupMembers,strsplit(NewCGroups(n))));
         if tf
            NewSortGroups(n) = missing;
         end
      end
      CustomOpts.SortGroupMembers = NewSortGroups;
      CustomOpts.SortColumns = ismember(NewCGroups, CustomOpts.SortGroupMembers);
   end
end


function [XData, YData] = reorderGroups(CustomOpts, XData, YData)
%REORDERGROUPS

   if CustomOpts.XGroupOrder == "none"
      switch CustomOpts.SortBy
         case "ascend"
            [~, idx] = sort(mean(YData(:, CustomOpts.SortColumns), 2));
            XData = reordercats(XData, string(XData(idx)));
         case "descend"
            [~, idx] = sort(mean(YData(:, CustomOpts.SortColumns),2), 'descend');
            XData = reordercats(XData, string(XData(idx)));
      end
   else
      [~, idx] = ismember(CustomOpts.XGroupOrder, string(XData));
      XData = reordercats(XData, string(XData(idx)));
      YData = YData(idx, :);
   end

end


function [H, L] = createCategoricalBarChart(XData,YData,CData,ydatavar,CustomOpts,varargs)
% Create the barchart

% Load default colors to match the mean symbols to the boxcharts
colors = defaultcolors;

% Note that "grouped" is default, use "BarLayout","stacked" for stacked
H = bar( XData, YData, 'FaceColor', 'flat', varargs{:}, 'Parent', CustomOpts.Parent);

% Color the bars
% for n = 1:length(H)
%    H(n).CData = n;
% end

% Add the legend
withwarnoff('MATLAB:legend:IgnoringExtraEntries'); 
legendtxt = CustomOpts.LegendText;
if legendtxt == ""
   legendtxt = unique(CData);
end
try
   L = legend(legendtxt, ...
      'Location', 'northwest', ...
      'AutoUpdate', 'off', ...
      'Orientation', CustomOpts.LegendOrientation, ...
      'FontSize', 12);

   %       'Location', 'northoutside', ...
   %       'AutoUpdate', 'off', ...
   %       'numcolumns', numel(legendtxt) );
catch
end

% Add a ylabel
ylabel(ydatavar);

% Format the plot
ax = gca;
set(ax, "YGrid", "on", "XGrid", "on", "XMinorTick", "off", "Box", "on");
set(ax.XAxis,'TickLength',[0 0]);

for n = 1:numel(H)
   H(n).LineWidth = 1;
   H(n).EdgeColor = "flat";
   H(n).FaceColor = colors(n,:);
   H(n).FaceAlpha = 0.3;
end

% % Note: this might work if table data is passed in with all the group data, but
% % in my example I used the metadata table from Info which already has the group
% % summary calcualtions so I cannot get the std
%
% % To get same order as the boxcharts, use [XData CData], not [CData XData]
% try
%    [mu, uv] = groupsummary(YData(:), [XData(:) CData], ["mean", "std"]); % uv = [uv{:}];
% catch
%    [mu, uv] = groupsummary(YData, XData, ["mean", "std"]); % uv = [uv{:}];
% end

% % To add labels:
% for n = 1:numel(H)
%    xtips = H(n).XEndPoints;
%    ytips = H(n).YEndPoints;
%    labels = string(H(n).YData);
%    text(xtips,ytips,labels,'HorizontalAlignment','center',...
%        'VerticalAlignment','bottom')
% end

end

function YData = mergecolumns_average(CustomOpts, YData)

% This might work, it tries to place the merged columns in the average posiiton
% of the original unmerged, but that might end up equaling the position of one
% of the dontmerge indexes so i just use the minimum value to ensure no
% conflicts

mergegroups = CustomOpts.MergeGroups;

% Calculate the mean index for each merge group
mergeindices = cellfun(@(group) mean(group), mergegroups);

% The 'dontmerge' columns stay unchanged
dontmerge = setdiff(1:size(YData, 2), horzcat(mergegroups{:}));

% Initialize the new matrix
NewYData = nan(size(YData,1), size(YData, 2));

% Combine the unchanged columns and the merge groups into one list,
% with the corresponding indices. The list is then sorted according to the indices.
columns = [num2cell(dontmerge); mergegroups];
indices = [dontmerge; mergeindices];
[~, order] = sort(indices);
columns = columns(order);

% Apply the operations (copy or merge) according to the ordered list
for n = 1:numel(columns)
   if numel(columns{n}) == 1  % Copy unchanged column
      NewYData(:, n) = YData(:, columns{n});
   else  % Merge group
      NewYData(:, n) = mean(YData(:, columns{n}), 2);
   end
end

YData = NewYData;

end




% % I moved anything out of here that was immediately applicable to above, whats
% left could be helpful for adding the mean +/- std idea
% function H = barchartcats(T,XData,YData,CData,ydatavar,method,varargs)
% % barchartcats(T,ydatavar,xgroupvar,cgroupvar, ...
% %    xgroupuse,cgroupuse,BoxChartOpts,CustomOpts)
%
% % Default method is 'mean'
% if nargin < 5
%    method = 'mean';
% end
%
% % Summarize the data
% if strcmp(method,'mean')
%    % [mu, uv, uc] = groupsummary(YData, [XData CData], ["mean", "std"]);
%    if istable(T)
%       G = groupsummary(T,{XData CData}, ["mean", "std"], YData);
%    else
%       G = groupsummary(T, [XData CData], ["mean", "std"], YData);
%    end
% elseif strcmp(method,'median')
%    % [mu, uv, uc] = groupsummary(YData, [XData CData], {"median", @iqr});
%    G = groupsummary(T, [XData CData], {"median", @iqr}, YData);
% end
%
% % % % % % % % % % % % % % % % % % % % % % % % % % %
%
% X = categorical(unique(metadata.basin));
% Y = nan(numel(X), numel(scenarios));
% for n = 1:numel(scenarios)
%    Y(:,n) = metadata.threshold(metadata.scenario == scenarios(n));
% end
%
% % Reorder from low to high POT
% [~,idx] = sort(mean(Y,2));
% X = reordercats(X,string(X(idx)));
%
% % % % % % % % % % % % % % % % % % % % % % % % % % %
%
% % Create the barchart
% H = bar( XData, mu, 'FaceColor', 'flat', varargs{:} );
%
% Add error bars
% hold on
% if strcmp(method,'mean')
%    for n = 1:length(mu)
%       errorbar(n, mu(n), sigma(n), 'k', 'LineStyle', 'none');
%    end
% elseif strcmp(method,'median')
%    for n = 1:length(mu)
%       errorbar(n, mu(n), q3(n)-q1(n), 'k', 'LineStyle', 'none');
%    end
% end
% hold off
%
% end
