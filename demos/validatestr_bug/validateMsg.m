function validateMsg(testcase, arg)
   if nargin < 1
      testcase = 1;
   end
   if nargin < 2
      arg = 'a';
   end
   switch testcase
      case 1
         validatestring(arg, {'b', 'c'}) % base case
      case 2
         validatestring(arg, {'b', 'c'}, 1) % include arg index
      case 3
         validatestring(arg, {'b', 'c'}, mfilename, 'arg', 2) % include filename, argname, and argindex
      case 4
         validateattributes(arg, {'double'}, {'nonempty'}) % base case
      case 5
         validateattributes(arg, {'double'}, {'nonempty'}, mfilename) % include filename
      case 6
         validateattributes(arg, {'double'}, {'nonempty'}, mfilename, 'arg') % include filename, and argname
      case 7
         validateattributes(arg, {'double'}, {'nonempty'}, mfilename, 'arg', 2) % include filename, argname, and argindex
   end
end