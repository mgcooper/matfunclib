function units = gettableunits(T,varargin)
%GETTABLEUNITS Return table var units as a cell array
% 
%  units = gettableunits(T) returns units for all variables in table T
% 
%  units = gettableunits(T,varnames) returns units for variables specified by
%  varnames in table T
% 
% See also

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
   