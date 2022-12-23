function tf = isgeostruct(S)
%ISGEOSTRUCT returns true or false for input S
%
%  tf = ISGEOSTRUCT(S);
%
% Author: Matt Cooper, MMM-DD-YYYY, https://github.com/mgcooper
%
% See also

%-------------------------------------------------------------------------------
% input parsing
%-------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = 'isgeostruct';
p.addRequired(   'S',                     @(x)isstruct(x)      );
p.parseMagically('caller');

%--------------------------------------------------------------------------

tf    = false;

if    isfield(S,'Geometry')                     && ...
      isfield(S,'BoundingBox')                  && ...
      any(isfield(S,{'Lat','Latitude'}))        && ...
      any(isfield(S,{'Lon','Longitude'}))

   tf = true;
end
