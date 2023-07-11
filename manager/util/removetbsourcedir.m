function removetbsourcedir(tfremovesource,tbpath)

if tfremovesource == true

   msg = '\n press ''y'' to remove (delete) source directory ';
   msg = [msg 'or any other key to cancel \n %s \n'];
   str = input(sprintf(msg,tbpath),'s');

   if string(str) == "y"
      system(sprintf('rm -r %s',rmtrailingslash(tbpath)));
   else
      return;
   end
end

function newpath = rmtrailingslash(oldpath)

if strcmp(oldpath(end),'/')
   newpath = oldpath(1:end-1);
else
   newpath = oldpath;
end