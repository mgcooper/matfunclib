function S = rmstructfields(S,fields)
   %RMSTRUCTFIELDS remove fields from scalar or non-scalar structure
   %
   % S = rmstructfields(S,fields) removes fields from structure S. fields is a
   % cellstr array of field names or char or string
   %
   % % Example with scalar struct
   % s.a = 1;
   % s.b = 2;
   % s.c = 3;
   %
   % s = rmstructfields(s, {'a', 'b'})
   %
   % % Example with nonscalar struct
   % s = arrayfun(@(x) struct('a', x), 1:10);
   % s = arrayfun(@(s, y) setfield(s, 'b', y), s, 2:11);
   % s = arrayfun(@(s, y) setfield(s, 'c', y), s, 3:12);
   %
   % s = rmstructfields(s, {'a', 'b'})
   %
   % See also

   % check inputs
   validateattributes(S, {'struct'}, {'nonempty'}, mfilename, 'S', 1)

   if ischar(fields) || isstring(fields)
      fields = cellstr(fields);
   end

   if isscalar(S)

      % for isscalar is the easy case, try this:
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
end
