function [xlocs,xleft,xright] = boxchartxdata(H)
%BOXCHARTXDATA retrieve x-axis data for boxcharts in handle H 
% 
% Syntax
%  xlocs = boxchartxdata(H) returns the xtick locations for each boxchart in H.
%  If H contains groups of boxchart, each element of H is a group of boxcharts
%  per xtick in the figure.
% 
% Inputs:
%  H = BoxChart graphics object (one group per element of H)
% 
% Outputs:
%  xlocs = array of xtick locations for each boxchart group in H
% 
% More detail:
% size(xlocs) = numel(cgroupvars) x numel(xgroupvars) = M x N
% size(H) = numel(cgroupvars) x 1 = M x 1
% 
% i.e., for a boxchart figure with: 
% N = numel(xgroupvars) (number of xticks), and
% M = numel(cgroupvars) (number of boxcharts per xtick), 
% 
% size(H) = M x 1 (number of boxcharts per xtick BY 1)
% size(xlocs) = M x N (number of boxcharts per xtick BY number of xticks)
% 
% 
% See also boxchartcats

% Each element of H is a set of boxcharts for one cgroup. The fifth element
% of H.NodeChildren is a "Quadrilateral" that defines the box chart face. There
% are 8 nodes per box (need to confirm if this is the case with notch on and off

% This might be helpful, but it's notch on that matters
% any(arrayfun(@(n) iscategorical(H(n).XData),1:numel(H)))
warning('off','MATLAB:handle_graphics:exceptions:SceneNode');
% warning('off','MATLAB:structOnObject')
drawnow;
% warning('on','MATLAB:structOnObject')
warning('on','MATLAB:handle_graphics:exceptions:SceneNode');

% Data dimensions
M = numel(H);

if all( [H.Notch] == 'on' )
   numVertsPerBox = 8;
else
   numVertsPerBox = 4;
end

% Functions to retrieve box vertices, count them, and reshape to per-box vals
Fverts = @(m) H(m).NodeChildren(5).VertexData(1,:);
Fcount = @(m) numel(Fverts(m)) / numVertsPerBox;
Fshape = @(m) reshape(Fverts(m), numVertsPerBox, []);

% Count the # of box vertices for all charts
N = arrayfun(Fcount,1:M);

% If every xtick had the same number of boxcharts:
% N = numel(H(1).NodeChildren(5).VertexData(1,:))/numVertsPerBox;

% Part 1 - Get the x-coordinates of the center of each boxchart
xlocs = nan(M,max(N));
xleft = nan(1,max(N));
xright = nan(1,max(N));
for m = 1:M
   
   xverts = double(Fshape(m));
   %xlocs(m,1:N(m)) = mean(xverts(1:2,:));
   
   % above works, but instead of 1:N(m), get the actual indices
   % I think this only works b/c the x-axis data is already numeric in this 
   xlocs(m,round(mean(xverts(1:2,:)))) = mean(xverts(1:2,:));
   
   % NOTE: this actually almost solved the case where boxchartcats is called
   % repeatedly, say its called once with no cgroupdata, then the xaxis is
   % centered on 1, and the xgroups are left and right of 1. Then it's called
   % again identically, now for some reason the xaxis is between 0 and 1, and
   % the xticks are (for a four-member xgroup) 0.2, 0.4, 0.6, and 0.8. So, I
   % think I may have a 'hold on' somewhere that i need to turn off so repeeated
   % calls overwrite it, ratehr than deal with it here. 
   % This might be needed, where xmean=round(mean(xverts(1:2,:)))
   % Find which x-coordinates are close to the rounded mean. I think this would
   % deal with the case where the boxcharts extend over the halfway mark b/w
   % xticks, but I don't think that's possible
   % xmean = round(mean(xverts(1:2,:)));
   % xidx = abs(xverts(1,:) - xmean) < 0.5;
   % xlocs(m,xidx) = mean(xverts(1:2,:));
   % Then xidx would be used like: xlocs(m,xidx) = mean(xverts(1:2,:))
    
   % Part 2 - Get the min/max bounds of each boxchart group
   switch m
      case 1
         xleft(round(mean(xverts(1:2,:)))) = xverts(1,:);
         %xleft = xverts(1,:);
      case M
         xright(round(mean(xverts(1:2,:)))) = xverts(2,:);
         %xright = xverts(2,:);
   end
end

if M == 1
   xright(round(mean(xverts(1:2,:)))) = xverts(2,:);
   %xright = xverts(2,:);
end

%%
% 
% Moved this into the loop for convencience
% 
% Part 2 - Get the min/max bounds of each boxchart group (the x-coordinate of
% the left side of the leftmost box and the x-coordinate of the right side of
% the rightmost box, for each set of boxcharts, one set per xtick). This is
% useful for adding shaded regions to distinguish groups.

% for m = 1, xVertexData(1,:) is the xlocs for the first boxchart in each xgroup
% for m = M, xVertexData(2,:) is the xlocs for the last boxchart in each xgroup

% xverts1 = double(reshape(H(1).NodeChildren(5).VertexData(1,:),8,[]));
% xvertsM = double(reshape(H(M).NodeChildren(5).VertexData(1,:),8,[]));
% xleft = xverts1(1,:);
% xright = xvertsM(2,:);


% Part 1 without initialization (work backwards):
% for n = numel(H):-1:1
%    xVertexData = double(reshape(H(n).NodeChildren(5).VertexData(1,:),8,[]));
%    xlocs(n,:) = mean(xVertexData(1:2,:));
% end

% Better to leave in matrix form for plotting against grouped data
% xlocs = xlocs(:);


%% For reference, using fun

% % This gets the xverts
% xverts = arrayfun( @(m) ...
%    double(reshape(H(m).NodeChildren(5).VertexData(1,:),8,[])), ...
%    1:M,'uni',0);
% 
% % This gets the xlocs
% xlocs = cellfun(@(x) mean(x(1:2,:)), xverts ,'uni',0);
% 
% % This gets the indices
% xnodes = cellfun(@(x) unique(round(x)), xlocs, 'uni', 0);
% 
% % This is a blank 1:9 vector that could be used to fill in 
% V = (1:max(N))';
% 
% % This gets the indices without computing 'xnodes' above
% I = cellfun(@(x) ismember((1:max(N))',x'), cellfun(@(x) ...
%    unique(round(x)), xlocs,'uni',0),'uni',0);
% I = horzcat(I{:});
% 
% % This gets the indices in one 'line'
% I = cellfun(@(x) ismember((1:max(N))',x'), ...
%    cellfun(@(x) unique(round(mean(x(1:2,:)))), arrayfun( @(m) ...
%    double(reshape(H(m).NodeChildren(5).VertexData(1,:),8,[])), ...
%    1:M,'uni',0),'uni',0),'uni',0);
% I = horzcat(I{:});
