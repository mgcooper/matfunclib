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
   %    OK is also FALSE when the project folder the directory records does not
   %    exist. VERIFYPROJECT then warns with the identifier
   %    matfunclib:verifyproject:missingFolder.
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
   ok = isproject(projname, 'require_project_folder_exists');

   % A registered project whose folder was moved or deleted cannot be
   % activated. Warn, so the caller knows why workon returned.
   if ~ok && isproject(projname)
      warning('matfunclib:verifyproject:missingFolder', ...
         'verifyproject: project folder %s does not exist', ...
         getprojectfolder(projname));
   end
end
