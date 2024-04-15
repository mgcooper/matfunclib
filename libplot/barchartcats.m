function varargout = barchartcats(T, ydatavar, xgroupvar, cgroupvar, opts, props)
   %BARCHARTCATS Bar chart by groups along x-axis and by color within groups.
   %
   % Description
   %
   % This function creates a bar chart of the data grouped by specified
   % categories.
   %
   % Syntax
   %
   % h = barchartcats(T, ydatavar) creates a bar chart, for column ydatavar in
   % table T. If T.(ydatavar) is a vector, then barchart creates a single bar
   % chart. In this mode, BARCHARTCATS behaves exactly like BOXCHART(ydata)
   % where ydata = T.(ydatavar).
   %
   % h = barchartcats(T, ydatavar, xgroupvar) groups the data in the vector
   % T.(ydatavar) according to the unique values in T.(xgroupvar) and plots each
   % group of data as a separate bar chart. xgroupdata determines the position
   % of each bar chart along the x-axis. ydata must be a vector, and xgroupdata
   % must have the same length as ydata.
   %
   % creates a bar chart, or bar plot, for column ydatavar in table T. If
   % T.(ydatavar) is a vector, then barchart creates a single bar chart. In this
   % mode, BARCHARTCATS behaves exactly like BOXCHART(ydata) where ydata =
   % T.(ydatavar).
   %
   % h = barchartcats(T, ydatavar, xgroupvar, cgroupvar, "XGroupMembers",
   %  xgroupmembers, "CGroupMembers", cgroupmembers) uses color to differentiate
   % between bar charts. The software groups the data in the vector ydata
   % according to the unique value combinations in xgroupdata (if specified) and
   % cgroupdata, and plots each group of data as a separate bar chart. The
   % vector cgroupdata then determines the color of each bar chart. ydata must
   % be a vector, and cgroupdata must have the same length as ydata. Specify the
   % 'GroupByColor' name-value pair argument after any of the input argument
   % combinations in the previous syntaxes.
   %
   % h = barchartcats(_, Name, Value) specifies additional chart options using
   % one or more name-value pair arguments. For a list of properties, see
   % BarChart Properties.
   %
   % Input Arguments:
   %
   % T - A table containing the data to be plotted.
   %
   % ydatavar - The name of the variable in the table T that contains the data
   % values for the bar chart.
   %
   % xgroupvar - The name of the categorical variable in the table T used to
   % define groups along the x-axis.
   %
   % cgroupvar - The name of the categorical variable in the table T used to
   % define groups for the colors of the bars.
   %
   % method - the method used in the call to groupsummary to compute the values
   % plotted as bars. The default method is 'mean'. For 'mean', the standard
   % deviation is also computed in the call to groupsummary to support the
   % addition of whiskers to the bars. If 'median' is passed in as the method,
   % the whiskers represent the interquartile range. Note: whiskers are not
   % currently supported.
   %
   % xgroupuse - A cell array of categories to be used for the x-axis grouping.
   %
   % cgroupuse - A cell array of categories to be used for the color grouping.
   %
   % Output Argument
   %
   % H: A handle to the created bar chart.
   %
   % Example
   %
   % This example reads data from a CSV file into a table T, and plots a bar
   % chart of the Value variable, grouped by the CategoryX and CategoryC
   % variables. The x-axis grouping includes categories 'Cat1', 'Cat2', and
   % 'Cat3', while the color grouping includes categories 'Group1' and 'Group2'.
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
   % h = barchartcats(T, ydatavar, xgroupvar, cgroupvar, xgroupuse, ...
   %    cgroupuse, 'Notch','on','MarkerStyle','none');
   %
   % Matt Cooper, 29-Nov-2022, https://github.com/mgcooper
   %
   % See also reordergroups, reordercats, barchart

   % TODO: add a "histogram" or "frequencies" or maybe "groupfilter" option in
   % which the xgroupvar is transformed to generate the values on the y axis. In
   % this case, ydatavar and xgroupvar would be the same, and the data would
   % therefor need to be numeric in an underlying sense or ordinal or otherwise
   % compatible with the transformation applied to the xgroupvar data. Could add
   % an option to use piechart instead of barchart. Or, this type of
   % functionality could go to piechartcats, and that function could have a
   % "DisplayType" option that uses bars instead of pies.

   % Add MergeGroups and PlotError to function signatures.
   % Check groupstats.histogram first, it uses MergeGroupVar/Members.

   arguments
      T table
      ydatavar (1,1) string {mustBeNonempty}
      xgroupvar (1,1) string {mustBeNonempty}
      cgroupvar string = string.empty()
      opts.XGroupMembers string = string.empty()
      opts.CGroupMembers string = string.empty()
      opts.RowSelectVar string = string.empty()
      opts.RowSelectMembers string = string.empty()
      opts.method (:,1) string { mustBeMember(opts.method, ...
         ["mean", "median"]) } = "mean"
      opts.SortBy (1,1) string { mustBeMember(opts.SortBy, ...
         ["ascend","descend","order","none"]) } = "none"
      % SortGroupMembers are members of cgroupvar to be used for computing the
      % sorting order of the xgroups. For example, if there are five xgroup
      % members i.e., five unique values of T.(xgroupvar), and three cgroup
      % members, i.e., three unique values of T.(cgroupvar), teh default
      % behavior of "ascend" is to compute the average value of the three cgroup
      % bars in each xgroup and sort by those average values. If instead you
      % want to sort by a particular cgroup member, specify them using
      % opts.SortGroupMembers.
      opts.SortGroupMembers (:,1) string = "all"
      opts.ShadeGroups (1,1) logical = true
      opts.PlotError (1,1) logical = true
      opts.MergeGroups (:,1) = []
      opts.XGroupOrder (:,1) string = "none"
      opts.CGroupOrder (:,1) string = "none"
      opts.Legend (:,1) string = "on"
      opts.LegendString (:,1) string = string.empty()
      opts.LegendOrientation (1, 1) string = "vertical"
      props.?matlab.graphics.chart.primitive.Bar
   end

   % import groupstats package
   import groupstats.groupselect
   import groupstats.boxchartxdata
   import groupstats.prepareTableGroups

   varargs = namedargs2cell(props);

   % validate inputs
   T = prepareTableGroups(T, ydatavar, string.empty(), xgroupvar, cgroupvar, ...
      opts.XGroupMembers, opts.CGroupMembers, ...
      opts.RowSelectVar, opts.RowSelectMembers);

   % barchartcats requires summarizing the data, unlike boxchart
   if istable(T)
      [XData, YData, CData, ~] = summarizeTableGroups( ...
         T, ydatavar, xgroupvar, cgroupvar, opts.method);
   else
      [XData, YData, CData, ~] = summarizeMatrixGroups( ...
         T, ydatavar, xgroupvar, cgroupvar, opts.method);
   end

   % main function

   % Todo: adapt the boxchartxdata method to plot the error whiskers

   % Note: right now group merging and group sorting are incompatible, e.g. if
   % merging is requested, then we effectively have new xgroups, so we don't
   % know how to use SortGroupMembers. It likely only matters for default case
   % right now, when SortGroupMembers is not specified, the firrst approach I
   % developed used all the xgroups, but if they're merged, that won't work, so
   % instead, I might need to find the indices and use them instead of
   % SortGroupMembers,

   % Need to add validation to ensure SortGroupMembers are members of CData

   % Custom group merging
   if isempty(opts.MergeGroups)
      % Find the columns to use for computing the sort
      if opts.SortGroupMembers == "all"
         opts.SortGroupMembers = string(unique(CData));
      end
      opts.SortColumns = ismember(string(unique(CData)), ...
         opts.SortGroupMembers);
   else
      [YData, opts] = mergeGroupColumns(opts, YData, CData);
   end

   % Custom ordering along x-axis
   [XData, YData] = reorderGroups(opts, XData, YData);

   % Create the figure
   [H, L, ax] = createCategoricalBarChart(XData, YData, CData, ydatavar, ...
      opts, varargs);

   hold off
   [varargout{1:nargout}] = dealout(H, L, ax);
end


function [XData, YData, CData, EData] = summarizeTableGroups(T, ydatavar, ...
      xgroupvar, cgroupvar, method)
   %SUMMARIZETABLEGROUPS

   % TODO
   % - check if two calls to groupsummary or similar has occurred in which case
   % there may be e.g. mean_mean_<var>. This would happen if I passed in a table
   % that was created with groupsummary, in which there is no need to summarize
   % the data further.
   % - Add a method to handle missing values e.g. in the above example, if a
   % binning method was used on the table outside this function, and a group has
   % no members for a bin, the table won't have the expected size based on the
   % number of cgroupvar or xgroupvar elements.

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

   % Each column of Y needs to correspond to a group of bars (each bar in a
   % group is a different color, each group is a different x-tick)
   % XData = reshape(XData, [], numel(xgroupuse));
   XData = unique(XData);
   YData = reshape(YData, numel(XData), []);
   EData = reshape(EData, numel(XData), []);

   % Aug 18, 2023, Moved this from the main function when prepareTableGroups
   try
      CData = T.(cgroupvar);
   catch
      CData = true(size(YData));
   end
end


function [XData, YData, EData] = summarizeMatrixGroups(T, YData, XData, ...
      CData, method)
   %SUMMARIZEMATRIXGROUPS

   % NOTE: Not functional, I don't think the calling syntax to groupsummary is
   % right, I think YData is not needed or needs to take the place of T.

   if strcmp(method, 'mean')
      % [mu, uv, uc] = groupsummary(YData, [XData CData], ["mean", "std"]);
      G = groupsummary(T, [XData CData], ["mean", "std"], YData);
   elseif strcmp(method, 'median')
      % [mu, uv, uc] = groupsummary(YData, [XData CData], {"median", @iqr});
      G = groupsummary(T, [XData CData], {"median", @iqr}, YData);
   end
end

function [NewYData, opts] = mergeGroupColumns(opts, YData, CData)
   %MERGEGROUPCOLUMNS

   % mergegroups is the YData column indices to merge, so the new YData needs to
   % contain the unmerged groups and the merged groups. The new YData are
   % ordered with the merged groups in the position of the smallest index for
   % that group and the unmerged groups in their original position relative to
   % the smallest index of the merged groups.
   mergegroups = opts.MergeGroups;
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

   % Also need to adjust opts.SortGroupMembers
   % Find the columns to use for computing the sort
   if opts.SortGroupMembers == "all"
      % Not sure we need to set the members, but if so, when merging, they lose
      % their meaning
      opts.SortGroupMembers = NewCGroups;
      opts.SortColumns = 1:size(NewYData, 2);
      % sortgroups = string(unique(CData));
   else
      % Find the members of mergegroups that are also in SortGroup?
      NewSortGroups = NewCGroups;
      for n = 1:numel(NewCGroups)
         tf = ~any(ismember(opts.SortGroupMembers,strsplit(NewCGroups(n))));
         if tf
            NewSortGroups(n) = missing;
         end
      end
      opts.SortGroupMembers = NewSortGroups;
      opts.SortColumns = ismember(NewCGroups, opts.SortGroupMembers);
   end
end

function [XData, YData] = reorderGroups(opts, XData, YData)
   %REORDERGROUPS

   if opts.XGroupOrder == "none"
      switch opts.SortBy
         case "ascend"
            [~, idx] = sort(mean(YData(:, opts.SortColumns), 2));
            XData = reordercats(XData, string(XData(idx)));
         case "descend"
            [~, idx] = sort(mean(YData(:, opts.SortColumns),2), 'descend');
            XData = reordercats(XData, string(XData(idx)));
      end
   else
      [~, idx] = ismember(opts.XGroupOrder, string(XData));
      XData = reordercats(XData, string(XData(idx)));
      YData = YData(idx, :);
   end
   % TODO: reorder the legend entries if custom ones provided
end

function [H, L, ax] = createCategoricalBarChart(XData, YData, CData, ydatavar, ...
      opts, props)
   % Create the barchart

   % Note that "grouped" is default, use "BarLayout","stacked" for stacked
   H = bar( XData, YData, 'FaceColor', 'flat', props{:});

   % For colors, if there are more bars than default colors, need to generate
   % colors, so I switched to the method below that uses n=1:length(H)

   % Load default colors to match the mean symbols to the boxcharts
   % colors = defaultcolors;

   % Add a ylabel
   ylabel(ydatavar);

   % Format the plot
   ax = gca;
   set(ax, "YGrid", "on", "XGrid", "on", "XMinorTick", "off", "Box", "on");
   set(ax.XAxis, 'TickLength', [0 0]);

   % Color the bars

   for n = 1:numel(H)
      H(n).LineWidth = 1;
      H(n).CData = n;
      H(n).EdgeColor = "flat";
      H(n).FaceAlpha = 0.75;
      %H(n).FaceColor = colors(n,:);
      %H(n).FaceAlpha = 0.3;
   end

   % Add the legend

   withwarnoff('MATLAB:legend:IgnoringExtraEntries');
   legendtxt = opts.LegendString;
   if isempty(legendtxt)
      legendtxt = unique(CData);
   end
   try
      L = legend(legendtxt, ...
         'Location', 'northwest', ...
         'AutoUpdate', 'off', ...
         'Orientation', opts.LegendOrientation, ...
         'FontSize', 12);
      % 'Location', 'northoutside', ...
      % 'AutoUpdate', 'off', ...
      % 'numcolumns', numel(legendtxt) );
   catch
   end

   set(L, 'Visible', opts.Legend)
   % % Note: this might work if table data is passed in with all the group data,
   % but % in my example I used the metadata table from Info which already has
   % the group % summary calcualtions so I cannot get the std
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

function YData = mergecolumns_average(opts, YData)

   % This might work, it tries to place the merged columns in the average
   % posiiton of the original unmerged, but that might end up equaling the
   % position of one of the dontmerge indexes so i just use the minimum value to
   % ensure no conflicts

   mergegroups = opts.MergeGroups;

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
% %    xgroupuse,cgroupuse,BoxChartOpts,opts)
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

%%
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
