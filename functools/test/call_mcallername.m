function name = call_mcallername(option)

   if nargin < 1
      option = 1;
   end

   switch option

      case 1
         name = mcallername('filename');

      case 2
         name = mcallername({'fullpath', 'filename'});

      case 3
         fnc = @() mcallername('filename');
         name = fnc();

      case 4

         % This shows that it returns 'mcallername' if stacklevel=1 in the local
         % function
         name = call_mcallername_localfunction();

      case 5
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % UPDATE : I changed it so it doesn't do what's described below but
         % keeping these notes for reference

         % This shows that it returns 'mcallername' if stacklevel=1 in the main
         % function

         % Maybe that's the intended behavior ... or accurate behavior ...
         % stacklevel = 1 is the function itself
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

         % call this from call_mcallername_2 ... the first two should return
         % call_mcallername_2 since that function is calling this one, the last
         % one should return this function since it is the second one down in
         % the stack ... note if I reverse the flipud in mcallername then its
         % the opposite so the KEY THING IS DECIDING WHETHER I WANT TO THINK IN
         % TERMS OF TOP DOWN OR BOTTOM UP

         cleanup = onCleanup(@() onCleanupFun());
         more on

         fprintf(1, '\nCalling mcallername from %s with no inputs ... \n', mfilename)
         fprintf(1, 'This should return the function which called this, or %s if called from base:\n', mfilename)
         name = mcallername() %#ok<*NOPRT>

         fprintf(1, '\nCalling mcallername from %s with "filename" ... \n', mfilename)
         fprintf(1, 'This should return the function which called this, or %s if called from base:\n', mfilename)
         name = mcallername('filename')

         fprintf(1, '\nCalling mcallername from %s with stacklevel=1 ... \n', mfilename)
         fprintf(1, 'This should return the function which called this, or %s if called from base:\n', mfilename)
         name = mcallername('filename', 'STACKLEVEL', 1)

         fprintf(1, '\nCalling mcallername from %s with stacklevel=2 ... \n', mfilename)
         fprintf(1, 'This should return this function name, %s, if the stack is more than two functions deep, or regardless of which called this, or %s if called from base:\n', mfilename)
         name = mcallername('filename', 'STACKLEVEL', 2);

      otherwise
   end
end
function onCleanupFun
   more off
end
function name = call_mcallername_localfunction()
   fnc = @() mcallername('filename');
   name = fnc();

   % Trying to understand why no arguments returns the expected result but
   % STACKLEVEL=1 returns 'mcallername'
   name = mcallername()
   name = mcallername('filename')
   name = mcallername('filename', 'STACKLEVEL', 2)
   name = mcallername('filename', 'STACKLEVEL', 1);
   % name = mcallername('filename', 'STACKLEVEL', 0);
end
