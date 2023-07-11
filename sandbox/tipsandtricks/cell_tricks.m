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

%% to use two cell arrays in cellfun, just pass it two cell arrays!

% something like:
% cellfun(@(x,y),C1,C2)

% see clipRasterByPoly and maybe test scripts in libraster/util
% This was how I first thought I could get it down to the minimum, then I
% realized that the whole reason the complicated vertcat was necessary is b/c
% each element of the cell arra produced by the areint arrayfun operation was
% either a scalar or a vector, but i only want the sum of the area of each one
% so in the second one I added the sum() and it was much easer. BUT FOR
% UNDERSTANDING hwo to do it in general, the first one provideds a good example
% of how to concatenate them when you don't want a sum and the elements can be
% irregular sized vectors
AON = cell2mat(arrayfun(@vertcat,cell2mat(arrayfun( ...
   @(n) areaint(PB(n).Vertices(:,2),PB(n).Vertices(:,1),E), (1:numel(PB))', ...
   'uniformoutput', false)),'uniformoutput', false));

AON = cell2mat(arrayfun( ...
   @(n) sum(areaint(PB(n).Vertices(:,2),PB(n).Vertices(:,1),E)),(1:numel(PB))', ...
   'uniformoutput', false));
   

% to access an index of the cell element being processed, pass in a cell array
% of indices of size equal to the cell array:
C = {'a', 'b', 'c', 'd'};
C = [C;C]
result = cellfun(@(idx) C{idx}, num2cell(1:numel(C))', 'UniformOutput', false);

% this si how i used it:
polyCellMapping = arrayfun(@(ipoly) find(W(:,ipoly)), (1:size(W,2)).', 'uni', 0);
polyCellWeights = cellfun(@(icell,ipoly) W(icell,ipoly) ./ sum(W(icell,ipoly)), ...
   polyCellMapping, num2cell(1:numel(polyCellMapping))', 'uni', 0);


% and thi sshows how it would be more complicated with arrayfun
polyCellWeights = arrayfun( @(ipoly) ...
   W(polyCellMapping{ipoly},ipoly)./sum(W(polyCellMapping{ipoly},ipoly)), ...
   (1:numel(PA))','uni',0);

% But this si how gpt said to do it in general
C = {'a', 'b', 'c', 'd'};
result = arrayfun(@(idx) processElement(C{idx}, idx), 1:numel(C), 'UniformOutput', false);

function out = processElement(element, idx)
    out = [element, num2str(idx)];
end

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

