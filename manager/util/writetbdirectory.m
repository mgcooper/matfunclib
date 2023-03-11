function writetbdirectory(toolboxes,dbpath)
if nargin == 1
   writetable(toolboxes,gettbdirectorypath());
else
   writetable(toolboxes,dbpath);
end