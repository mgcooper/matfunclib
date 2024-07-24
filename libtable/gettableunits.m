function units = gettableunits(tbl, varargin)
   %GETTABLEUNITS Return table variable units as a cell array
   %
   %  units = gettableunits(tbl) returns units for all variables in TBL.
   %
   %  units = gettableunits(tbl, varnames) returns units for variables specified
   %  by VARNMAES in TBL.
   %
   % See also

   if nargin == 1
      units = tbl.Properties.VariableUnits;
   else
      vars = varargin{1};
      allvars = gettablevarnames(tbl);
      allunits = tbl.Properties.VariableUnits;
      if numel(allvars) == numel(allunits)
         units = allunits(ismember(allvars,vars));
      else % this should be the case where units is empty
         units = allunits;
      end
   end

   % This is useful for printing to the screen but bad in general
   % if numel(unique(units)) == 1
   %    units = unique(units);
   % end
end
