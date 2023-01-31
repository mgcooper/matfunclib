function S = geostructinit(geometry,numfeatures,varargin);
%geostructinit initializes a geostructure S with geometry
% 
%  S = geostructinit(geometry,numfeatures); 
%  Creates a geostruct S of size(1,numfeatures) and specified geometry
%  'line','point', or 'polygon'.
% 
%  S = geostructinit(geometry,numfeatures,'fieldnames',fieldnames);
%  Creates a geostruct S of size(1,numfeatures) and specified geometry
%  'line','point', or 'polygon' and fields specified by 'fieldnames'
%  name-value input.
% 
%  Author: Matt Cooper, Sep-23-2022, https://github.com/mgcooper
% 
%  See also

%--------------------------------------------------------------------------
% input parsing
%--------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

p.addRequired(   'geometry',              @(x)ischar(x)           );
p.addRequired(   'numfeatures',           @(x)isnumeric(x)        );
p.addParameter(  'fieldnames',   '',      @(x)ischar(x)|iscell(x) );

p.parseMagically('caller');

fieldnames = p.Results.fieldnames;
   
%--------------------------------------------------------------------------

% NOTE: the geostruct will not be a true geostruct until the BoundingBox
% field is added, which can be achieved with updategeostruct

% make sure the geometry is capitalized
geometry(1) = upper(geometry(1));

% init a geo struct
[S(1:numfeatures).Geometry]  = deal(geometry);
[S(1:numfeatures).Lon]       = deal(nan);
[S(1:numfeatures).Lat]       = deal(nan);

for n = 1:numel(fieldnames)
   [S(1:numfeatures).(fieldnames{n})] = deal(nan);
end

% if this is done, then subsequent calls to updategeostruct (e.g. after the
% lat/lon values are filled in) will not create the BoundingBox field, so
% only do this if lat/lon is provided to this fucntion, which isn't
% implemented yet)
% S = updategeostruct(S);








