function S = nonscalarstruct(S,varargin)
   %NONSCALARSTRUCT convert scalar struct to non-scalar struct
   %
   %  S = NONSCALARSTRUCT(S) converts scalar struct S to a non-scalar struct
   %
   % % Example
   %
   % S.a = 1:10;
   % S.b = 2:11;
   % S.c = 3:12;
   %
   % S = nonscalarstruct(S);
   %
   % Matt Cooper, 10-Mar-2023, https://github.com/mgcooper
   %
   % See also

   % input checks
   narginchk(1,1)

   % For now, this only supports conversion, not initialization
   S = table2struct(struct2table(S));

   if isscalar(S)

      sizes = structfun(@numel, S);

      assert(all(sizes == sizes(1)), 'All fields must have the same size');

      fields = fieldnames(S);
      S2 = struct();
      for n = 1:sizes(1)
         for m = 1:numel(fields)
            S2(n).(fields{m}) = S.(fields{m})(n);
         end
      end
      S = S2;
   end
end
