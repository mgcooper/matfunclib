function closeopenfiles()
   %CLOSEOPENFILES close all files open in the matlab editor
   %
   %  closeopenfiles()
   %
   % See also reopenfiles, reopentabs, openprojectfiles, reopentabs, savetabs

   % No-op headless: the editor API needs the desktop, and workoff must
   % stay runnable in -batch sessions.
   if ~usejava('desktop')
      return
   end
   openDocuments = matlab.desktop.editor.getAll;
   openDocuments.close;
end
