function x = rowvec(x)
   %ROWVEC Convert array to row vector.
   %
   % x = rowvec(x)
   %
   % See also: vec, tocolumn, torow

   x = transpose(x(:));
   % x=reshape(x,[],1)
end
