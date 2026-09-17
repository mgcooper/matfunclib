function tf = isdoublevector(x)
   %ISDOUBLEVECTOR Return true if input X is a double vector.
   %
   %  tf = isdoublevector(x) returns true if x is class double and a vector.
   %
   % See also: isdoublescalar, isnumericvector
   tf = isa(x,'double') && isvector(x);
end
