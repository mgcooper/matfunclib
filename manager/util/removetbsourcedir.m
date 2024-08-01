function removetbsourcedir(tfremovesource, tbpath)
   %REMOVETBSOURCEDIR Move toolbox source directory to trash
   %
   %
   % See also:

   if tfremovesource

      msg = '\n press ''y'' to remove (delete) source directory ';
      msg = [msg 'or any other key to cancel \n %s \n'];
      str = input(sprintf(msg, tbpath), 's');

      if strcmp(str, 'y')

         % Prior method used system, new method added to allow recycle on.
         % system(sprintf('rm -r %s', rmtrailingslash(tbpath)));

         previousState = recycle("on");
         cleanupJob = onCleanup(@() recycle(previousState));

         % Remove folder and subfolders (use option 's')
         [status, message, ~] = rmdir(rmtrailingslash(tbpath), 's');

         if ~status
            disp(message)
         end

      else
         return
      end
   end
end
function newpath = rmtrailingslash(oldpath)

   if strcmp(oldpath(end), '/')
      newpath = oldpath(1:end-1);
   else
      newpath = oldpath;
   end
end
