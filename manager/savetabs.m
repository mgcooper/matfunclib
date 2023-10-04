function filelist = savetabs()

   % note - this is identical to save_open-files in archive until i get in the
   % habit of calling this, then delete that

   opentabs = matlab.desktop.editor.getAll;
   filelist = string({opentabs.Filename});
   filelist = filelist(:);

   tabspath = [getenv('MATLABUSERPATH') 'opentabs/matlab_editor/'];
   fsave    = [tabspath 'open_' date '.mat'];

   if exist(fsave,'file')
      n = 1;
      fsave = [strrep(fsave,'.mat','') '_' num2str(n) '.mat'];

      while exist(fsave,'file')
         n = n+1;
         fsave = strrep(fsave,num2str(n-1),num2str(n));
      end
   end
   save(fsave,'filelist');
   cd(tabspath);
end
