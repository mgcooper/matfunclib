function varargout = cell_tricks(varargin)
%CELL_TRICKS cell tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

% these were in tabletricks, I didn't think of adding these types of calls when
% I renamed to _tricks
% cd(fullfile(getenv('MATLABFUNCTIONPATH'),'libcells'));
% doc cell

%%

% flatten cell arrays. if a cell array contains arrays with a common number of
% columns, it can be flattened like this. 

% use a polylinez shapefile as an example:
fname    = '/Users/coop558/work/data/interface/GIS_data/Killik_River';
S        = m_shaperead(fname);
C        = S.ncst;

% each entry in C is an nx3 cell array, the first value is the longitude, second
% is latitude, third is z. I can flatten the entire thing like this:
Cflat    = vertcat(C{:});

% or this
Cflat    = cell2mat(C);

% but what if I don't want to flatten it, and instead I want three nx1 versions
% of C? The use case here is to get cell arrays of lat,lon as nested cell arrays
% to pass to polyjoin to insert nan's correctly. 

% the loop way:
for n = 1:numel(C)   
   latcells{n} = C{n}(:,2);
   loncells{n} = C{n}(:,1);
   zcells{n} = C{n}(:,3);
end
[lat,lon] = polyjoin(latcells,loncells);

% the vectorized way:
latcells = cellfun(@(x)vertcat(x(:,2)),C,'Uni',0);
loncells = cellfun(@(x)vertcat(x(:,1)),C,'Uni',0);
[lat,lon] = polyjoin(latcells,loncells);

% turns out I can insert nan's myself:
latcells = cellfun(@(x)vertcat(x(:,2),nan),C,'Uni',0);
loncells = cellfun(@(x)vertcat(x(:,1),nan),C,'Uni',0);
lat      = vertcat(latcells{:});
lon      = vertcat(loncells{:});


plotm(lat,lon);

% % in one step? couldn't fiture it out
% % this gets us each cell2mat(C(1))
% % cell2mat(C)
% lat = cellfun(@(x)vertcat(cell2mat(x(1))),C)
% lat = cellfun(@(x)vertcat(cell2mat(x(:,2)),nan),C,'uni',0)
% lat = cellfun(@(x)vertcat(cell2mat(x),[nan,nan,nan]),C,'uni',0)
% 
% lat = cellfun(@(x)vertcat(x,nan),C{:}(:,1))
% lat = cellfun(@(x)vertcat(x,nan),C(:,1))

% this just puts one nan at the end
% Cflat    = vertcat(C{:},[nan,nan,nan]);







% to find indices of common elements of two cell arrays
% use ismember

pets        = {'cat';'dog';'dog';'dog';'giraffe';'hamster'}
species     = {'cat' 'dog'}
[tf, loc]   = ismember(pets, species)

