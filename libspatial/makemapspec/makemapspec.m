function S = makemapspec(geometry,varargin)
%MAKEMAPSPEC general description of function
% 
% Syntax:
% 
%  S = MAKEMAPSPEC(geometry);
%  S = MAKEMAPSPEC(geometry,'numfeatures',numfeatures);
% 
% Author: Matt Cooper, MMM-DD-YYYY, https://github.com/mgcooper
% 

%--------------------------------------------------------------------------
% input parsing
%--------------------------------------------------------------------------
   p                 = MipInputParser;
   p.FunctionName    = 'makemapspec';
   p.CaseSensitive   = false;
   p.KeepUnmatched   = true;
   p.addRequired(   'geometry',              @(x)ischar(x)        );
   p.addParameter(  'numfeatures',  1,       @(x)isnumeric(x)     );
   p.parseMagically('caller');
   
%--------------------------------------------------------------------------
    
c = distinguishable_colors(numfeatures);
for n = 1:numfeatures
   switch lower(geometry)
      case 'polygon'
          S(n) = makesymbolspec('Polygon',{'Default',          ...
                      'FaceColor','none',                         ...
                      'EdgeColor',c(n,:),                         ...
                      'LineWidth',1});
      case 'point'
          S(n) = makesymbolspec('Point',{'Default',            ...
                      'Marker','o',                               ...
                      'MarkerSize',6,                             ...
                      'MarkerFaceColor',c(n,:),                   ...
                      'MarkerEdgeColor','none'});
      case 'line'
          S(n) = makesymbolspec('Line',{'Default',             ...
                      'Color',c(n,:),                             ...
                      'LineWidth',1});
   end
end















