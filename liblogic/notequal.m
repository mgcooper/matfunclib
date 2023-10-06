function TF = notequal(X1,X2)
   %NOTEQUAL Compare non-equality of two inputs.
   %
   %  TF = NOTEQUAL(X1, X2) Returns true if X1 and X2 are not equal
   %
   % Matt Cooper, 03-Feb-2023, https://github.com/mgcooper
   %
   % See also: notempty, notnan, notall, nonenan, none

   TF = ~isequal(X1,X2);
end
