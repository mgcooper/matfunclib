function str = struct2nameval(opts)
% Collapses a name-value struct into comma and colon markup.
%
%   str = struct2nameval(opts)
%
% STRUCT2NAMEVAL examples:
% 
% s.name1 = 'val1';
% s.name2 = 'val2';
% args = optionsToNamedArguments(s)
% 
%  s = struct();%          ->  0×0 empty string array
%  struct2nameval(s)  
% 
%  s.Name1 = "Value1";%    ->  "Name1=Value1"
%  struct2nameval(s)  
% 
%  s.Name2 = "Value2";%    ->  "Name1=Value1,Name2=Value2"
%  struct2nameval(s)  
% 
%  s.Name3 = 7;%           ->  "Name1=Value1,Name2=Value2,Name3=7"
%  struct2nameval(s)  
% 
% See also: optionsToNamedArguments, unmatched2varargin, namedargs2cell

arguments
   opts (1, 1) struct
end

if isempty(fieldnames(opts))
   str = string.empty();
   return
end

fcn = @(f) compose("%s=%s", f, format(opts.(f)));
str = strjoin(cellfun(fcn, fieldnames(opts)), ",");

function s = format(v)
   if isnumeric(v)
      s = string(num2str(v));
   elseif not(isscalar(v))
      s = arrayfun(@format, v);
   elseif ismissing(v)
      s = "<missing>";
   else
      s = string(v);
   end

   if not(isscalar(v))
      s = "[" + s + "]";
   end
end

end