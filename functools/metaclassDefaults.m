function fromclass = metaclassDefaults(fromclass, metaClass)
%METACLASSDEFAULTS assign metaclass defaults to fromclass struct
% 
% 
% 
% See also:

arguments
   fromclass struct
   metaClass meta.class
end

% https://www.mathworks.com/matlabcentral/answers/760546-function-argument-validation-from-class-properties-ignores-defaults

p = metaClass.PropertyList;
for n = 1:length(p)
   if p(n).HasDefault && ~isfield(fromclass, p(n).Name)
      fromclass.(p(n).Name) = p(n).DefaultValue;
   end
end