function h = formaterrorbar(h,varargin)
%FORMATERRORBAR apply formatting to error bar
%
%  h = formaterrorbar(h,varargin);
%
% See also: formatplotmarkers, figformat

%-------------------------------------------------------------------------------
p                 = magicParser;
p.CaseSensitive   = false;
p.FunctionName    = mfilename;

p.addParameter('linestyle',   '-',        @(x)ischar(x)                 );
p.addParameter('marker',      'o',        @(x)ischar(x)                 );
p.addParameter('linewidth',   1.5,        @(x)ischar(x)                 );
p.addParameter('color',       [.3 .3 .3], @(x)isnumeric(x)||ischar(x)   );
p.addParameter('edgecolor',   [.2 .2 .2], @(x)isnumeric(x)||ischar(x)   );
p.addParameter('facecolor',   [.7 .7 .7], @(x)isnumeric(x)||ischar(x)   );
p.addParameter('capsize',     0,          @(x)isnumeric(x)              );
p.addParameter('markersize',  8,          @(x)isnumeric(x)              );
p.addParameter('alpha',       0.5,        @(x)isnumeric(x)              );
p.parseMagically('caller');
alpha = p.Results.alpha;
color = p.Results.color;
%-------------------------------------------------------------------------------

if ischar(color)
   color = rgb(color);
end

if sum(facecolor) ~= sum(color) && sum(facecolor) ~= sum([.7 .7 .7])
   color = facecolor;
end

% apply the formatting
set(h                                  , ...
   'LineStyle'         , linestyle        , ...
   'Color'             , color            , ...
   'LineWidth'         , linewidth        , ...
   'Marker'            , marker           , ...
   'MarkerSize'        , markersize       , ...
   'MarkerEdgeColor'   , edgecolor        , ...
   'MarkerFaceColor'   , facecolor        , ...
   'CapSize'           , capsize          );


% note: in order to get the below to work, the line and the face color need
% to be the same, but i think theres a way to convert the rbg triplet to
% the color code used in h.Line.ColorData at the link below in which case i
% could add checks for the case where i pass in facecolor but not color

% https://www.mathworks.com/matlabcentral/answers/473325-how-to-make-errorbar-transparent

% set transparency of the bars
set([h.Bar, h.Line], 'ColorType', 'truecoloralpha',   ...
   'ColorData', [h.Line.ColorData(1:3); 255*alpha])

% set transparency of marker faces
set(h.MarkerHandle, 'FaceColorType', 'truecoloralpha',   ...
   'FaceColorData', [h.Line.ColorData(1:3); 255*alpha])

% set transparency of the caps (didn't confirm this
set(h.CapH, 'EdgeColorType', 'truecoloralpha', ...
   'EdgeColorData', [h.Cap.EdgeColorData(1:3); 255*0.5])

% the end caps on the errorbar were still solid, but I was able to make them
% transparent with other undocumented properties in the errorbar object. In
% case someone else may be trying to do the same thing:
% The hidden properties h.CapH and h.MarkerHandle can be adjusted the same
% way as h.Line and h.Bar as above, but use FaceColorData & FaceColorType
% and EdgeColorData & EdgeColorType properties in place of ColorData &
% ColorType (or can be set to 'visible','off').



