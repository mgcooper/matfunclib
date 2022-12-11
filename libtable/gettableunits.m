function units = gettableunits(T,varargin)
%GETTABLEUNITS Return table var units as a cell array
if nargin == 1
   units = T.Properties.VariableUnits;
else
   vars = varargin{1};
   allvars = gettablevarnames(T);
   allunits = T.Properties.VariableUnits;
   if numel(allvars) == numel(allunits)
      units = allunits(ismember(allvars,vars));
   else % this should be the case where units is empty
      units = allunits;
   end
end
   