function moved = renametbsourcedir(tfrenamesource,oldtbpath,newtbpath,force)
   %RENAMETBSOURCEDIR Move a toolbox source folder, with a prompt unless forced.
   %
   %  moved = renametbsourcedir(tfrenamesource, oldtbpath, newtbpath, force)
   %  returns true when the folder moved. It returns false when
   %  TFRENAMESOURCE is false or the user declined the prompt, so the
   %  caller can tell a declined move from a completed one (audit MEDIUM
   %  17). movefile does the move; it works on every platform and reports
   %  failure by its status output. A failed move raises
   %  matfunclib:renametbsourcedir:moveFailed with movefile's message.
   arguments
      tfrenamesource (1, 1) logical
      oldtbpath (1, :) {mustBeFolder}
      newtbpath (1, :) {mustBeTextScalar}
      force (1, 1) logical = false
      % dryrun (1, 1) logical = false % dryrun is in calling functions
   end

   moved = false;
   if tfrenamesource == true
      % some older entries in the directory have the trailing slash
      oldtbpath = rmtrailingslash(oldtbpath);
      newtbpath = rmtrailingslash(newtbpath);

      if force == true
         % move without prompt
         moved = movefolder(oldtbpath, newtbpath);
      else
         % move after prompt confirmation
         msg = '\n renaming source directory from "%s" to "%s"\n\n press ';
         msg = [msg ' ''y'' to proceed or any other key to cancel\n'];
         str = input(sprintf(msg,oldtbpath,newtbpath),'s');

         if string(str) == "y"
            moved = movefolder(oldtbpath, newtbpath);
         else
            return
         end
      end
   end
end

function moved = movefolder(oldtbpath, newtbpath)
   %MOVEFOLDER Move the folder with movefile and turn a failure into an error.
   [ok, message] = movefile(oldtbpath, newtbpath);
   if ~ok
      error('matfunclib:renametbsourcedir:moveFailed', ...
         'renametbsourcedir: could not move %s to %s (%s).', ...
         oldtbpath, newtbpath, strtrim(message));
   end
   moved = true;
end

function newpath = rmtrailingslash(oldpath)
   if strcmp(oldpath(end),'/')
      newpath = oldpath(1:end-1);
   else
      newpath = oldpath;
   end
end
