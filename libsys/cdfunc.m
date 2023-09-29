function cdfunc(funcname)
   %CDFUNC cd to folder containing function FUNCNAME
   %
   %  cdfunc(FUNCNAME) cd to the folder containing function FUNCNAME
   %
   % Matt Cooper, 18-NOV-2022, https://github.com/mgcooper
   %
   % See also cd, cdback, cdenv, cdfex, cdfunc, cdhome, cdproject, cdtb, withcd

   % PARSE INPUTS
   narginchk(0,1)

   % CLEANUP OBJ
   thisdir = pwd();
   cleanup = onCleanup( @() setenv('OLD_CWD', thisdir) );

   % MAIN CODE
   if nargin==1
      % Find the function location, including built-ins.
      funcname = convertStringsToChars(funcname);
      if ~strncmp(reverse(funcname), 'm.', 2)
         funcname = [funcname '.m'];
      end
      if ~ismfile(funcname)
         % add all subfolders to the path in case the function was just made
         try
            pathadd(getenv('MATLABFUNCTIONPATH'));
         catch
         end
      end
      funcpath = fileparts(which(funcname)); % use the first one on the path
   elseif isenv('MATLABFUNCTIONPATH')
      % Go to the function directory
      funcpath = getenv('MATLABFUNCTIONPATH');
   else
      error('function not found');
   end

   cd(funcpath)
end
