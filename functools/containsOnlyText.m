function tf = containsOnlyText(x)
   %CONTAINSONLYTEXT Return true if the input contains only text values.
   %
   %  TF = CONTAINSONLYTEXT(X) returns true when X is text or a container of
   %  text values, including mixed char/string cell arrays.
   %
   %  This predicate overlaps with MATLAB's MUSTBETEXT, but it remains useful
   %  as a reusable boolean test and for mixed char/string cell arrays that the
   %  built-in validation does not handle consistently.
   %
   % See also istextlike ischarlike mustContainOnlyText mustBeText
   % mustBeTextScalar mustBeTextScalarOrEmpty mustBeNonzeroLengthText

   tf = istextlike(x);
end
