function mustBeColumnWise(a)
   %MUSTBECOLUMNWISE Validate that value is a n-by-1 or n-by-m array
   %
   %  MUSTBECOLUMNWISE(A) throws an error if A is not a n-by-1 or n-by-m array.
   %
   % See also: MUSTBEVECTOR.

   % Check if the input is a column or array of columns (ie, not a row vector)
   if size(a,1) == 1 && size(a,2) > 1
      eidSize = 'mustBeColumnWise:notColumnWise';
      msgSize = 'Input must not be a row vector.';
      throwAsCaller(MException(eidSize, msgSize))
   end
end
