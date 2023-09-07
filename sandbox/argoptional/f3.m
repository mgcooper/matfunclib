function y = f3(~, x2, x3)
   
   arguments
      ~
      x2
      x3
   end
   
   if nargin == 3
      % this tests calling syntax f3(1, 1, 1)
      % although nargin does equal 3, the first input is not in the workspace,
      % so it doesn't work to assign to x1
      % x1 = ... can't do this either b/c 
   end
   y = x2 + x3;
end