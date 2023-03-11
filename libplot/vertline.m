function h = vertline(x,varargin)
%VERTLINE puts a vertical line on the plot at point x

% nov 2022 renamed to vertline to avoid conflict with built-in stats/private
% dec 2022 removed input parsing
%------------------------------------------------------------------------------
% p = magicParser;
% p.FunctionName=mfilename;
% p.addRequired('x',@(x)isnumeric(x));
% p.addOptional('ax',gca,@(x)isaxis(x));
% p.parseMagically('caller');
%------------------------------------------------------------------------------

% todo: make the line adjust if the limits change / zoom etc.
hold on; ax = gca;
ylims = ax.YLim;
h = plot(ax,[x x],ylims,':k',varargin{:});
% hold off;