function removetbsourcedir(tfremovesource,tbpath)

   if tfremovesource == true
      
      msg = '\n press ''y'' to remove (delete) source directory ';
      msg = [msg 'or any other key to cancel \n %s \n'];
      str = input(sprintf(msg,tbpath),'s'); 

      % 1:end-1 removes the trailing '/'
      if string(str) == "y"
         system(sprintf('rm -r %s',tbpath(1:end-1)));
      else
         return;
      end
   end