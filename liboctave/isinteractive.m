function tf = isinteractive()
   %ISINTERACTIVE Determine if the program is being run interactively or not.
   %
   %  tf = isinteractive()
   %
   % See also: isoctave

   if isoctave
      tf = isguirunning;
   else
      % matlab, this test doesn't work for Octave
      % don't use batchStartupOptionUsed as it neglects the "-nodesktop" case
      tf = usejava('desktop');
   end
end
