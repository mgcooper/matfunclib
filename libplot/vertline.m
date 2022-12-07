function h = vline(x,varargin)
%VLINE puts a vertical line on the plot at point x

%--------------------------------------------------------------------------
% parse inputs
p = MipInputParser;
p.FunctionName='vline';
p.addRequired('x',@(x)isnumeric(x));
p.addOptional('ax',gca,@(x)isaxis(x));
p.parseMagically('caller');
%--------------------------------------------------------------------------

% todo: make the line adjust if the limits change / zoom etc.

hold on;
ylims = ax.YLim;

h = plot(ax,[x x],ylims,':k');

hold off;