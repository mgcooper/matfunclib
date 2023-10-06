function idx = findjumps(x)
   %FINDJUMPS Find jumps in array.
   %
   % idx = findjumps(x)
   % 
   % See also:

   idx = find(cumsum(diff(x(:), 2)) ~= 0) + 2;

   % % for debugging
   % % convert to column
   % x = x(:);
   % % check the first two values
   % d12 = [x(2)-x(1), x(3)-x(2)];
   % dx1 = diff(x, 1);
   % dx2 = diff(x, 2);
   %
   % % make dx1 and dx2 the same size as x
   % dx1 = [dx1(1); dx1];
   % dx2 = [0; 0; dx2];
end
