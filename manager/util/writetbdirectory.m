function writetbdirectory(toolboxes, tbDirectoryPath)
   if nargin == 1
      writetable(toolboxes, gettbdirectorypath());
   elseif nargin == 2
      writetable(toolboxes, tbDirectoryPath);
   else
      error('not enough inputs')
   end
end
