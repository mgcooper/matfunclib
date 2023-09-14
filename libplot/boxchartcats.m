function varargout = boxchartcats(T, ydatavar, xgroupvar, cgroupvar, ...
      CustomOpts, BoxChartOpts)
   arguments
      T tabular
      ydatavar (1,1) string { mustBeNonempty }
      xgroupvar (1,1) string { mustBeNonempty }
      cgroupvar string = string.empty()
      CustomOpts.XGroupMembers (:, 1) string = groupmembers(T, xgroupvar)
      CustomOpts.CGroupMembers (:, 1) string = groupmembers(T, cgroupvar)
      CustomOpts.RowSelectVar string = string.empty()
      CustomOpts.RowSelectMembers (:, 1) string = groupmembers(T, RowSelectVar)
      CustomOpts.PlotMeans (1,1) logical = true
      CustomOpts.ShadeGroups (1,1) logical = true
      CustomOpts.ConnectMeans (1,1) logical = false
      CustomOpts.ConnectMedians (1,1) logical = false
      CustomOpts.Legend (1,1) string = "on"
      CustomOpts.LegendText string = string.empty()
      BoxChartOpts.?matlab.graphics.chart.primitive.BoxChart
   end
   %BOXCHARTCATS  box chart by groups along x-axis and by color within groups
   %
   % Description
   %
   % This function creates a box chart of the data grouped by specified
   % categories.
   %
   % Syntax
   %
   % h = boxchartcats(T, ydatavar) creates a box chart, or box plot, for column
   % DATAVAR in table T. If T.(DATAVAR) is a vector, then boxchart creates a
   % single box chart. In this mode, BOXCHARTCATS behaves exactly like
   % BOXCHART(ydata) where ydata = T.(ydatavar).
   %
   % h = boxchartcats(T, ydatavar, xgroupvar) groups the data in the vector
   % T.(DATAVAR) according to the unique values in T.(xgroupvar) and plots each
   % group of data as a separate box chart. xgroupdata determines the position
   % of each box chart along the x-axis. ydata must be a vector, and xgroupdata
   % must have the same length as ydata.
   %
   % creates a box chart, or box plot, for column DATAVAR in table T. If
   % T.(DATAVAR) is a vector, then boxchart creates a single box chart. In this
   % mode, BOXCHARTCATS behaves exactly like BOXCHART(ydata) where ydata =
   % T.(ydatavar).
   %
   % h = boxchartcats(T, ydatavar, xgroupvar, cgroupvar, xgroupuse, cgroupuse)
   % uses color to differentiate between box charts. The software groups the
   % data in the vector ydata according to the unique value combinations in
   % xgroupdata (if specified) and cgroupdata, and plots each group of data as a
   % separate box chart. The vector cgroupdata then determines the color of each
   % box chart. ydata must be a vector, and cgroupdata must have the same length
   % as ydata. Specify the 'GroupByColor' name-value pair argument after any of
   % the input argument combinations in the previous syntaxes.
   %
   % h = boxchartcats(_, Name, Value) specifies additional chart options using
   % one or more name-value pair arguments. For example, you can compare sample
   % medians using notches by specifying 'Notch','on'. Specify the name-value
   % pair arguments after all other input arguments. For a list of properties,
   % see BoxChart Properties.
   %
   % Input Arguments
   %
   % T: A table containing the data to be plotted. ydatavar: The name of the
   % variable in the table T that contains the data values for the box chart.
   % xgroupvar: The name of the categorical variable in the table T used to
   % define groups along the x-axis. cgroupvar: The name of the categorical
   % variable in the table T used to define groups for the colors of the boxes.
   % xgroupuse: A cell array of categories to be used for the x-axis grouping.
   % cgroupuse: A cell array of categories to be used for the color grouping.
   % varargin: Additional optional arguments for the boxchart function.
   %
   % Output Argument
   %
   % H: A handle to the created box chart.
   %
   % Example
   %
   % This example reads data from a CSV file into a table T, and plots a box
   % chart of the Value variable, grouped by the CategoryX and CategoryC
   % variables. The x-axis grouping includes categories 'Cat1', 'Cat2', and
   % 'Cat3', while the color grouping includes categories 'Group1' and 'Group2'.
   %
   % T = readtable('data.csv'); ydatavar = 'Value'; xgroupvar = 'CategoryX';
   % cgroupvar = 'CategoryC'; xgroupuse = {'Cat1', 'Cat2', 'Cat3'}; cgroupuse =
   % {'Group1', 'Group2'};
   %
   % h = boxchartcats(T, ydatavar, xgroupvar, cgroupvar, xgroupuse, cgroupuse);
   %
   % Use optional arguments:
   %
   % h = boxchartcats(T, ydatavar, xgroupvar, cgroupvar, xgroupuse, cgroupuse,
   % ...
   %    'Notch','on','MarkerStyle','none');
   %
   % Matt Cooper, 29-Nov-2022, https://github.com/mgcooper
   %
   % See also reordergroups, reordercats, boxchart

   % Note, if notch is off, the mean looks nice as a solid white circle. If notch
   % is on, the mean may fall outside the shaded region, so face color is needed.

   % To add custom whiskers:
   % arrayfun(@(n) set(H(n),'WhiskerLineStyle','none'),1:numel(H))
   % then plot custom ones

   % Note, the columns need to be categorical, but the 'x/cgroupvar' and
   % 'xgroupuse/c' inputs can be strings/chars/cellstr or categorical. Specifying
   % 'string' in the arguments block performs an implicit conversion to string, and
   % ismember('someCategoricalVariable','someStringVariable') works but iff the
   % string is scalar (or cell array of chars), so the approach taken here is to
   % convert to string. In a few places, attention is needed to convert to string
   % if non-scalar string/categorical comparisons are made.

   %---------------------- parse arguments
   
   % Override default BoxChart settings
   ResetFields = {'JitterOutliers','Notch'};
   ResetValues = {true,'on'};
   for n = 1:numel(ResetFields)
      if ~ismember(ResetFields{n},fieldnames(BoxChartOpts))
         BoxChartOpts.(ResetFields{n}) = ResetValues{n};
      end
   end
   varargs = namedargs2cell(BoxChartOpts);
   %--------------------------------------

   % import groupstats package
   import gs.groupselect
   import gs.boxchartxdata
   import gs.prepareTableGroups

   %---------------------- validate inputs
   T = prepareTableGroups(T, ydatavar, string.empty(), xgroupvar, cgroupvar, ...
      CustomOpts.XGroupMembers, CustomOpts.CGroupMembers, ...
      CustomOpts.RowSelectVar, CustomOpts.RowSelectMembers);

   % Assign the data to plot
   XData = T.(xgroupvar);
   YData = T.(ydatavar);
   try
      CData = T.(cgroupvar);
   catch
      CData = true(size(YData));
   end
   %---------------------- main function

   hold off % repeated calls create problems

   % Add a legend
   H = categoricalBoxChart(XData, YData, CData, ydatavar, CustomOpts, varargs);

   % If "markerstyle", "none" is in varargin, clip the ylimits to the data
   setboxchartylim(H);

   % Add the means if requested
   plotboxchartstats(CustomOpts,H,XData,YData,CData);

   % Add shaded bars to distinguish groups if requested
   shadeboxchartgroups(CustomOpts,H);

   % for troubleshooting
   % muTbl = groupsummary(Tplot,{xgroupvar,cgroupvar}, "mean", ydatavar);
   if CustomOpts.Legend == "off"
      legend off
   end

   hold off
   switch nargout
      case 1
         varargout{1} = H;
   end
end

%% Local Functions
function H = categoricalBoxChart(XData, YData, CData, YDataVar, CustomOpts, varargs)
   
   % Create the box chart
   H = boxchart( XData, YData, 'GroupByColor', CData, varargs{:} );
   
   % Add the legend
   withwarnoff('MATLAB:legend:IgnoringExtraEntries');
   legendtxt = CustomOpts.LegendText;
   if isempty(legendtxt)
      legendtxt = unique(CData);
   end
   try
      legend(legendtxt, ...
         'Orientation', 'horizontal', ...
         'Location', 'northoutside', ...
         'AutoUpdate', 'off', ...
         'numcolumns', numel(legendtxt) );
   catch
   end

   % Add a ylabel
   ylabel(YDataVar);

   % Format the plot
   set(gca, "YGrid", "off", "XGrid", "off", "XMinorTick", "off", "box", ...
      "on", "TickLength", [0 0]);
end

function plotboxchartstats(opts,H,XData,YData,CData)

   hold on;

   % Load default colors to match the mean symbols to the boxcharts
   colors = defaultcolors;

   % Get the x-coordinate of each boxchart center and the mean of each boxchart
   [mu, med, xlocs] = boxchartstats(H, XData, YData, CData);

   % Plot the means
   if opts.PlotMeans
      arrayfun(@(n) scatter(xlocs(n,:), mu(n,:), 30, colors(n, :), 'filled', 's'), ...
         1:numel(H));
   end

   % Connect the means. This only works for now with single-group cats
   if opts.ConnectMeans == true
      plot(xlocs, mu, '-', 'Color', [0.5 0.5 0.5],'HandleVisibility','off')
   end

   % Connect the medians.
   if opts.ConnectMedians
      plot(xlocs, med, '-', 'Color', [0.5 0.5 0.5],'HandleVisibility','off')
   end

end


function [mumat, medmat, xlocs] = boxchartstats(H, XData, YData, CData);

   % Get the x-coordinate of each boxchart center
   [xlocs] = boxchartxdata(H);

   % To get same order as the boxcharts, use [XData CData], not [CData XData]
   try
      [mu, uv] = groupsummary(YData, [XData CData], "mean"); % uv = [uv{:}];
      med = groupsummary(YData, [XData CData], "median");
   catch
      [mu, uv] = groupsummary(YData, XData, "mean"); % uv = [uv{:}];
      med = groupsummary(YData, XData, "median");
   end
   % Table format: muTbl = groupsummary(Tplot,{xgroupvar,cgroupvar}, "mean", ydatavar);

   % If there were no missing charts on any xticks:
   % mumat = reshape(mu,size(xlocs));

   % Instead, need to map from xlocs to mu,uv using missing values in xlocs
   mumat = nan(size(xlocs));
   medmat = nan(size(xlocs));
   try
      mumat(~isnan(xlocs)) = mu(ismember(uv{:,2},unique(CData)));
      medmat(~isnan(xlocs)) = med(ismember(uv{:,2},unique(CData)));
   catch
      mumat(~isnan(xlocs)) = mu(ismember(uv,unique(XData)));
      medmat(~isnan(xlocs)) = med(ismember(uv,unique(XData)));
   end

end


function shadeboxchartgroups(CustomOpts, H)

   if CustomOpts.ShadeGroups == false
      return
   end

   % Get the x-coordinate of the bounds of each boxchart group (the left/right-most
   % x-coordinate of each xtick group)
   [~, xleft, xright] = boxchartxdata(H);

   % Get the y-coordinate of the plot bounds
   [ylow, yhigh] = bounds(ylim);

   % since we know the data is regular, fill nan's
   xleft = naninterp1(1:numel(xleft),xleft,'linear','extrap');
   xright = naninterp1(1:numel(xright),xright,'linear','extrap');

   % To extend the shaded region halfway between each group:
   try
      dx = mean((xleft(2:end) - xright(1:end-1)),'omitnan') / 2;
   catch
      % This means there is only one box, maybe no shading?
      dx = (xright - xleft) / 2;
   end

   xleft = xleft - dx;
   xright = xright + dx;

   idxodd = 1:2:numel(xleft);
   xpatch = [xleft(idxodd); xright(idxodd); xright(idxodd); xleft(idxodd); xleft(idxodd)];
   ypatch = repmat([ylow; ylow; yhigh; yhigh; ylow], 1, numel(idxodd));

   P = patch(xpatch, ypatch, 'k', ...
      'FaceColor', [0.5 0.5 0.5], ...
      'FaceAlpha', 0.1, ...
      'EdgeColor', 'none' );

   % Set up a listener for changes in the YLim property
   ax = gca;
   addlistener(ax, 'YLim', 'PostSet', @(src, evt) updateshadedbounds(P, ax));

   function updateshadedbounds(P, ax)
      P.YData = repmat([ax.YLim(1); ax.YLim(1); ax.YLim(2); ax.YLim(2); ax.YLim(1)], ...
         1, size(P.Faces,1));
   end

end

function setboxchartylim(H);

   if all({H.MarkerStyle}=="none")

      drawnow;

      ywhiskers = arrayfun(@(n) transpose(H(n).NodeChildren(4).VertexData(2,:)), ...
         1:numel(H),'uni',0);

      ywhiskers = vertcat(ywhiskers{:});

      % Compute axis limits with padding
      ylim(minmax(ywhiskers) + [-0.01 0.01]*diff(minmax(ywhiskers)));
   end

end

% % This was stuff in boxchartstats and/or plotboxchartmeans I did not end up using
%
% % Get the unique values on the X-axis
% uX = unique(XData);
%
% % Get the number of xticks (number of boxchart groups)
% NumX = numel(xgroupuse);
% NumG = numel(cgroupuse);
% symbols = defaultmarkers("closed");
% sizes = [8, 8, 12, 8, 12];

% % More explicit, for reference:
% unique_cats = unique(CData);
% unique_cats_vector = uv{:,2};
% notmissing = ~isnan(xlocs);
% mu_matrix = nan(size(xlocs));
% for n = 1:numel(unique_cats)
%    mu_matrix(n,notmissing(n,:)) = mu(unique_cats_vector==unique_cats(n));
% end
%
% % This was the concise form of above before I saw the final version
% ucats = unique(CData);
% mumat = nan(size(xlocs));
% for n = 1:numel(ucats)
%    mumat(n,~isnan(xlocs(n,:))) = mu(uv{:,2}==ucats(n));
% end

% just in case the version above that first allocates nan(size(xlocs)) fails
% mumat(~isnan(xlocs)) = mu(ismember(uv{:,2},unique(CData)));
% mumat = reshape(mumat,size(xlocs)); mumat(isnan(xlocs)) = NaN;



% % This does the same thing above does, but may be more useful. Note, ismember
% % works b/w categorical and string iff the string is scalar
% if any(~ismember(xgroupuse, string(unique(T.(xgroupvar)))))
%    error('all elements of xgroupuse must be members of the set T.(xgroupvar)')
% end
% if any(~ismember(cgroupuse, string(unique(T.(cgroupvar)))))
%    error('all elements of cgroupuse must be members of the set T.(cgroupvar)')
% end

% % This should not be necessary b/c I set cgroupuse/x to all values in
% c/xgroupvar for the case where they are "none",

% % Subset the rows for the cgroup and xgroup variables
% if cgroupuse == "none"
%    incgroup = true(height(T),1);
% else
%    incgroup = ismember(T.(cgroupvar),cgroupuse);
% end
%
% if xgroupuse == "none"
%    inxgroup = true(height(T),1);
% else
%    inxgroup = ismember(T.(xgroupvar),xgroupuse);
% end
%
% iplot = incgroup | inxgroup;


% % If both xgroupvar & cgroupvar are "none", there is no grouping variable
% if xgroupvar == "none" && cgroupvar == "none"
%    error('No xgroupvar or cgroupvar was specified, use boxchart')
%
%    % Could call createCategoricalBoxChart, or H = boxchart(T.(ydatavar))
%    % H = createCategoricalBoxChart(XData,YData,CData,ydatavar,varargs);
% end
%
% if cgroupvar == "none" % use all categorical variables
%    cgroupvar = string(gettablevarnames(T,'categorical'));
% end


% ypatchnew = repmat([y_limits(1) y_limits(1) y_limits(2) y_limits(2) y_limits(1)], numel(P), 1);
% ypatch = repmat([ylow; ylow; yhigh; yhigh; ylow], 1, numel(idxodd));
% P.YData = repmat(ypatch_new(i, :);

% % Function to update the patch's y-limits
% function updateshadedbounds(P, ax)
%    ypatchnew = repmat( ...
%       [ax.YLim(1); ax.YLim(1); ax.YLim(2); ax.YLim(2); ax.YLim(1)], ...
%       1, size(P.Faces,1));
%    for n = 1:size(P.Faces,1)
%       if isvalid(P(n))
%          P(n).YData = ypatchnew(:,n);
%       end
%    end
% end

% shaded bars

% function shadeboxchartgroups(shadegroups,H)
%
% if shadegroups == false
%    return
% end
%
% % Get the x-coordinate of the bounds of each boxchart group (the left/right-most
% % x-coordinate of each xtick group)
% [~,xleft,xright] = boxchartxdata(H);
%
% % get the y-coordinate of the plot bounds
% [ylow,yhigh] = bounds(ylim);
%
% % to extend the shaded region halfway between each group:
% dx = (xleft(2)-xright(1))/2;
% xleft = xleft - dx;
% xright = xright + dx;
%
% h_patch = gobjects(ceil(numel(xleft))/2,1);
% for n = 1:2:numel(xleft)
%
%    xpatch = [xleft(n) xright(n) xright(n) xleft(n) xleft(n)];
%    ypatch = [ylow ylow yhigh yhigh ylow];
%
%    h_patch(n) = patch('XData',xpatch,'YData',ypatch, ...
%       'FaceColor',[0.5 0.5 0.5], ...
%       'FaceAlpha',0.1, ...
%       'EdgeColor','none');
% end
% ax = gca;
% % Set up a listener for changes in the YLim property
% addlistener(ax, 'YLim', 'PostSet', @(src, evt) updateshadedbounds(h_patch, ax));
%
% % Function to update the line's y-limits
% function updateshadedbounds(h_patch, ax)
%     y_limits = ax.YLim;
%     h_patch.YData = y_limits;
% end
%
% % % Create a sample plot
% % x = 1:10;
% % y = rand(1, 10);
% % plot(x, y, 'o-');
% % hold on;
% %
% % % Get the current axes
% % ax = gca;
% %
% % % Plot a vertical line at x=5
% % x_line = 5;
% % y_limits = ax.YLim;
% % h_line = line([x_line, x_line], y_limits);
% end

% Translation between boxchart and groupsummary
%  boxchart    groupsummary(T,...)     groupsummary(A,...)
% ----------  --------------------     -------------------
% xgroupdata   groupvars{1} (varname)  groupvars(:,1) (column vector)
% cgroupdata   groupvars{2} (varname)  groupvars(:,2) (column vector)
% ydata        datavars     (varname)  A              (column vector)
% N/A          method
% N/A          groupbins = actual bin edges or method, for both T and A syntax
%
% For boxchart, I think the bin edges are the xvertex coordinates of each box



%% This clarifies the array vs table syntax for calling groupsummary

% % Array format: A and groupvars must have the same number of rows. groupvars can
% % have multiple columns, to create multiple groups
% A = T.(ydatavar);
% groupvars = T.(cgroupvar);
% [mu, uv] = groupsummary(A, groupvars, "mean");
%
% % This produces the data needed for boxchartcats
% A = T.(ydatavar);
% groupvars = [T.(cgroupvar) T.(xgroupvar)];
% [mu, uv] = groupsummary(A, groupvars, "mean");
% uv = horzcat(uv{:});
%
% % Using XData,YData,CData
% A = double(YData);
% groupvars = [CData XData];
% [mu, uv] = groupsummary(A, groupvars, "mean");
% uv = horzcat(uv{:});
%
% % Table format
% groupvars = {cgroupvar,xgroupvar};
% muTbl = groupsummary(T,groupvars, "mean", ydatavar);
%
% NOTE: none of these scatter/gscatter options seem to give what I want, because
% they plot the group means
%
% scatter as of r2021b can plot data from a table
% This is what we want to add to the plot, but the data are stacked vertically
% instead of jittered horizontally which would be needed to plot directly on top
% of boxchart, so probably easiest to use the method to get the boxchart verties
% figure; hold on;
% for n = 1:numel(uX)
%    idx = ismember(muTbl.scenario,uX(n));
%    scatter(muTbl(idx,:),"scenario","mean_FCS",'filled')
% end
%
% Next ones plot all the data, I think it automatically computes unique values,
% because it isn't plotting all the FCS values
%
% figure; scatter(T,"scenario","FCS",'filled')
%
% now we can use gscatter
% figure; gscatter(XData,double(YData),CData)


% these do not work
% figure; gscatter(XData,double(YData),{cgroupvar,xgroupvar})
% figure; gscatter(XData,double(YData),[CData XData])

% This was how I originally figured it out, I had to loop over the x vars before
% I figrued out to pass in two grouping vars as in the above examples
% for n = 1:numel(uX)
%    % [mu(n), uv(n)] = groupsummary(qpeaks, FCS, 'mean');
%
%    idx = Tplot.(xgroupvar) == uX(n);
%
%    % this works, using YData and CData
%    % [mu, uv] = groupsummary(A, groupvars, method)
%    % A = T.(ydatavar)
%    % [mu(:,n), uv] = groupsummary(double(YData(idx)), CData(idx), 'mean');
%
%    % this works, using array syntax + indexing into the table
%    %mu(:,n) = groupsummary(Tplot.(ydatavar)(idx),Tplot.(cgroupvar)(idx), 'mean');
%
%    % this works, using table syntax, but it returns a table
%    % mu(:,n) = groupsummary(Tplot(idx,:),cgroupvar, 'mean',ydatavar);
% end

%% LICENSE
%
% BSD 3-Clause License
%
% Copyright (c) 2023, Matthew Guy Cooper (mgcooper) All rights reserved.
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
%    contributors may be used to endorse or promote products derived from this
%    software without specific prior written permission.
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
