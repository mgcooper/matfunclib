function tf = isgeostruct(S)
%ISGEOSTRUCT returns true or false for input S
%
%  tf = ISGEOSTRUCT(S);
%
% Author: Matt Cooper, MMM-DD-YYYY, https://github.com/mgcooper
%
% See also

%% parse inputs
persistent parser
if isempty(parser)
   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.addRequired('S',@isstruct);
end
parse(parser, S);

%% main
tf = isfield(S,'Geometry') && ...
   isfield(S,'BoundingBox') && ...
   any(isfield(S,{'Lat','Latitude'})) && ...
   any(isfield(S,{'Lon','Longitude'}));
