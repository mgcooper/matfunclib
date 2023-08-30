function demo_assert(testname)

   % generate t and q with different size
   t = 1:2;
   q = 1:3;
   
   % generate a string that is not a member of a set
   str = 'notvalid';
   validstrs = {'validstr1', 'validstr2'};
   
switch testname

   case 'validatestring1'
      validatestring(str, validstrs)
      
   case 'validatestring2'
      validatestring(str, validstrs, mfilename, 'STR', 1)
      
   case 'validateattributes1'
      validateattributes(t, {'double'}, {'size', size(q)})
      
   case 'validateattributes2'
      validateattributes(t, {'double'}, {'size', size(q)}, mfilename, 't', 1)
      
   case 'assert1'
      assert(numel(t) == numel(q), 'Expected input number 1, t, and 2, q, to have equal size')
      
   case 'assert2'
      assert(numel(t) == numel(q), ['bfra:' mfilename ':wronginputsize'], ...
         'Expected input number 1, t, and 2, q, to have equal size')
      
   case 'error'
      if numel(t) ~= numel(q)
         error(['bfra:' mfilename ':wronginputsize'], ...
            'Expected input number 1, t, and 2, q, to have equal size')
      end
      
end