function h = vertline(x,varargin)
%VERTLINE puts a vertical line on the plot at point x

% renamed vline to vertline nov 2022 to avoid conflict with built-in
% stats/private
%--------------------------------------------------------------------------
% parse inputs
p = MipInputParser;
p.FunctionName='vertline';
p.addRequired('x',@(x)isnumeric(x));
p.addOptional('ax',gca,@(x)isaxis(x));
p.parseMagically('caller');
%--------------------------------------------------------------------------

% todo: make the line adjust if the limits change / zoom etc.

hold on;
ylims = ax.YLim;

h = plot(ax,[x x],ylims,':k');

hold off;