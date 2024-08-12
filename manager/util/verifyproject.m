function ok = verifyproject(projname)
   %VERIFYPROJECT Verify if project exists in the project directory.
   %
   %    ok = verifyproject(projname)
   %
   %  Description
   %    OK = VERIFYPROJECT(PROJNAME) checks if PROJNAME exists in the project
   %    directory. If it does not, an option to add it to the directory is
   %    presented. If the project exists or the option to add it to the
   %    directory is confirmed, OK is returned as TRUE, otherwise ok is FALSE.
   %
   % See also: isproject addproject workon

   if ~isproject(projname)
      msg = 'project not found in directory, press ''y'' to add it ';
      msg = [msg 'or any other key to return\n'];
      str = input(msg, 's');
      if strcmpi(str, 'y')
         addproject(projname);
      end
   end
   ok = isproject(projname);
end
