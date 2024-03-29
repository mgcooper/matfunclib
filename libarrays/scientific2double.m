function [D,T] = scientific2double(C,ndigits)
   %SCIENTIFIC2DOUBLE Convert from scientific to standard notation with n digits
   %
   % [D,T] = scientific2double(C,ndigits) converts numbers displayed as
   % scientific notation within a column, row, or table to regular notation with
   % n digits.
   %
   % See also

   if ~iscell(C)
      C = num2cell(C);
   end

   fun = @(x) sprintf(['%0.' int2str(ndigits) 'f'], x);
   D = cellfun(fun, C, 'UniformOutput',0);

   % convert to column
   for n = 1:length(D)
      N(n) = str2double(D{n});
   end
   % Convert to a table
   T = cell2table(D);
end
