function call_mcallername_2(option)
   % call mcallername from stack level 2

   if nargin < 1
      option = 1;
   end

   cleanup = onCleanup(@() onCleanupFun());
   more on

   % Call mcallername directly from this function to see how the stacklevel is
   % interpreted from THIS function
   fprintf(1, '\nCalling mcallername from %s with stacklevel=1 ... \n', mfilename)
   fprintf(1, 'This should return the function which called this, or %s if called from base:\n', mfilename)
   name = mcallername("stacklevel", 1) %#ok<*NOPRT>
   fprintf(1, '\nCalling mcallername from %s with stacklevel=2 ... \n', mfilename)
   fprintf(1, 'This should also return %s if called from base because the stack is only one level deep, or the function which called this:\n', mfilename)
   name = mcallername("stacklevel", 2)

   % Call call_mcallername to see how the stacklevel is interpreted from THAT
   % function
   fprintf(1, '\nCalling call_mcallername from %s\n', mfilename)
   call_mcallername(option)

   % Decided I prefer directly printing name = ... to the screen
   % fprintf(1, ['  -> ' mcallername("stacklevel", 1) '\n'])
   % fprintf(1, ['  -> ' mcallername("stacklevel", 2) '\n'])
end

function onCleanupFun
   more off
end
