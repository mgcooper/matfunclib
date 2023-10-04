function savegraphics(h,filename,saveflag,makedir)
   %SAVEGRAPHICS Save graphics to file using exportgraphics.
   %
   % savegraphics(h, filename, saveflag, makedir)
   % 
   % See also

   arguments
      h (1,:) matlab.ui.Figure = gcf
      filename (1,:) string = ""
      saveflag (1,1) logical = true
      makedir (1,1) logical = true
   end

   if saveflag == true

      for n = 1:numel(h)

         % foldername will be empty if a filename is passed in, use pwd
         foldername = string(fileparts(filename(n)));

         if foldername ~= "" && ~isfolder(foldername) && makedir == true

            mkdir(fullfile(fileparts(filename(n))));
         end

         exportgraphics(h(n),filename(n),'Resolution',200);
      end
   end
end
