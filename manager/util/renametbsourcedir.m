function renametbsourcedir(tfrenamesource,oldtbpath,newtbpath,force)

   if tfrenamesource == true
      
      % some older entries in the directory have the trailing slash
      oldtbpath = rmtrailingslash(oldtbpath);
      newtbpath = rmtrailingslash(newtbpath);
      
      if force == true
         
         % move without prompt
         system(sprintf('mv %s %s',oldtbpath,newtbpath));
         
      else
         
         % move after prompt confirmation
         
         msg = '\n renaming source directory from %s to %s\n\n press ';
         msg = [msg ' ''y'' to proceed or any other key to cancel\n'];
         str = input(sprintf(msg,oldtbpath,newtbpath),'s'); 
            
         if string(str) == "y"
               
            system(sprintf('mv %s %s',oldtbpath,newtbpath));
            
         else
            % abort
            return;
         end
         
      end
   end
   
function newpath = rmtrailingslash(oldpath)

if strcmp(oldpath(end),'/')
   newpath = oldpath(1:end-1);
else
   newpath = oldpath;
end