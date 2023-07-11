function T = settableunits(T,units)
%SETTABLEUNITS set table units property
% 
% T = settableunits(T,'m3') sets the 'VarialbeUnits' for every variable in T to
% 'm3'.
% 
% See also: settableprops

% parse inputs
[T, units] = parseinputs(T, units);

% TODO: change this or create wrapper 'settableprops' with option to set
% varnames, units, etc. The main thing this accomplishes is setting the
% units when they're the same for every column, otherwise we need to create
% the cell array and then it's just a simple assignment, but this could be
% expanded to enforce naming conventions and maybe even use the unit class

N = size(T,2);
if numel(string(units)) == 1
   units = repmat(string(units),N,1);
elseif numel(string(units)) ~= N
   error('either one unit for all columns or one unit per column required');
end
T.Properties.VariableUnits = units;


function [T, units] = parseinputs(T, units);

p = inputParser;
p.FunctionName = mfilename;
p.CaseSensitive = false;
p.KeepUnmatched = true;

addRequired(p, 'T', @(x)istable(x) || istimetable(x) );
addRequired(p, 'units', @(x)ischar(x) || iscell(x) );
parse(p,T,units);
T = p.Results.T;
units = p.Results.units;