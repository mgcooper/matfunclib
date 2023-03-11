function S = rmstructfields(S,fields)
%RMSTRUCTFIELDS remove fields from scalar or non-scalar structure
% 
% S = rmstructfields(S,fields) removes fields from structure S. fields is a
% cellstr array of field names or char or string

if ischar(fields) || isstring(fields)
   fields = cellstr(fields);
end

if isscalar(S)
   
   % UPDATE 10 Mar 2023, I think isscalar is the easy case, try this:
   try
      S = rmfield(S,fields);
   catch
      for n = 1:numel(fields)
         S.(fields{n}) = [];
      end
   end
else
   
   % I thought this might fail b/c of non-scalar fields but it works
   T = struct2table(S);
   T = removevars(T,fields);
   S = table2struct(T);
   
end
   
