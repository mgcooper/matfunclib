function tf = isnumericscalar(x)
   %ISNUMERICSCALAR Return true if input X is a numeric scalar.
   %
   %  tf = isnumericscalar(x) returns true if x is numeric and scalar.
   %
   % See also: isnumericvector, isdoublescalar
   tf = isnumeric(x) && isscalar(x);
end
