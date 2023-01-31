function H = scatterfit(varargin)
%scatterfit plots x versus y with a lin-reg fit and a one:one line
%
%  H = scatterfit(x,y)
%
% AUTHOR: Matthew Guy Cooper, UCLA, guycooper@ucla.edu
%
% EXAMPLE 1: simplest case, just add the one to one line
% x = 1:1:100;
% y = x.*(rand(1,100) + .5);
% h = scatter(x,y);
% addOnetoOne;
%
% EXAMPLE 2: change the default 1:1 line to a black dashed line
% x = 1:1:100;
% y = x.*(rand(1,100) + .5);
% h = scatter(x,y);
% addOnetoOne('k--')
%
% EXAMPLE 3: change the default 1:1 line to very thick line;
% x = 1:1:100;
% y = x.*(rand(1,100) + .5);
% h = scatter(x,y);
% addOnetoOne('k--','linewidth',5)
%
% See also: addonetoone.m

% if nargin==0
%     posneg = pos;
% elseif nargin>0
%     if strcmp(posneg,'positive')
%     end
% end

% Ensure 2 or 3 inputs.
narginchk(2, 3)

switch nargin
   case 2                  % scatterfit(x,y)
      f = gcf;
      x = varargin{1};
      y = varargin{2};
   otherwise               % scatterfit(f, x, y)
      f = varargin{1};
      x = varargin{2};
      y = varargin{3};
end

% Create the chart axes and scatter plot.
H.figure = f;
H.ax = axes('Parent', f);
H.plot = plot(H.ax,x,y,'o');  % scatter(ax, x, y, 6, "filled")
hold on;
formatPlotMarkers;

% Compute and create the best-fit line.
m = fitlm(x, y);
H.linearfit = plot(H.ax,x,m.Fitted,'LineWidth',2);
H.onetoone = addOnetoOne;

% later add options to pass x/ylabel
xylabel('x data','ydata')
legend('data','linear fit','1:1 line')



