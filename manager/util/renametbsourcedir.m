function renametbsourcedir(tfrenamesource,oldtbpath,newtbpath)

   if tfrenamesource == true
      
      msg = '\n renaming source directory from %s to %s\n\n press ';
      msg = [msg ' ''y'' to proceed or any other key to cancel\n'];
      str = input(sprintf(msg,oldtbpath,newtbpath),'s'); 

      % 1:end-1 removes the trailing '/'
      if string(str) == "y"
         system(sprintf('mv %s %s',oldtbpath(1:end-1),newtbpath(1:end-1)));
      else
         return;
      end
   end