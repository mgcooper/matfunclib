function tbl = settableunits(tbl,units)
   %SETTABLEUNITS set table units property
   %
   %  tbl = settableunits(tbl,units)
   %
   % Example
   %  tbl = settableunits(tbl,'m3') sets the 'VarialbeUnits' for every variable
   %  in tbl to 'm3'.
   %
   % See also: settableprops

   % parse inputs
   [tbl, units] = parseinputs(tbl, units);

   % TODO: change this or create wrapper 'settableprops' with option to set
   % varnames, units, etc. The main thing this accomplishes is setting the
   % units when they're the same for every column, otherwise we need to create
   % the cell array and then it's just a simple assignment, but this could be
   % expanded to enforce naming conventions and maybe even use the unit class

   N = size(tbl,2);
   if numel(string(units)) == 1
      units = repmat(string(units),N,1);
   elseif numel(string(units)) ~= N
      error('either one unit for all columns or one unit per column required');
   end
   tbl.Properties.VariableUnits = units;
end

function [tbl, units] = parseinputs(tbl, units);

   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;

   addRequired(parser, 'tbl', @(x)istable(x) || istimetable(x) );
   addRequired(parser, 'units', @(x)ischar(x) || iscell(x) );
   parse(parser,tbl,units);
   tbl = parser.Results.tbl;
   units = parser.Results.units;
end
