function tf = isdoublematrix(x)
   tf = isa(x,'double') && ismatrix(x);