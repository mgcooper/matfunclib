function props = tableprops(T,varargin)

if nargin == 1
   vars  = string(T.Properties.VariableNames);
   units = string(T.Properties.VariableUnits);
else
   vars = varargin{1};
   allvars = string(T.Properties.VariableNames);
   allunits = string(T.Properties.VariableUnits);
   if numel(allvars) == numel(allunits)
      ivars = ismember(allvars,vars);
      units = string(T.Properties.VariableUnits(find(ivars)));
   else % this should be the case where units is empty
      units = allunits;
   end
end

props    = [vars;units];
   
%    vars  = cellstr(T.Properties.VariableNames);
%    units = string(T.Properties.VariableUnits);
%    
%    props = table(units,'VariableNames',vars,'RowNames','units')
%    
%    props = table([vars;units],'RowNames',{'vars','units'})
   