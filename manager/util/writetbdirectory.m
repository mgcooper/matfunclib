function writetbdirectory(toolboxes,dbpath)
if nargin == 1
   writetable(toolboxes,gettbdirectorypath());
elseif nargin == 2
   writetable(toolboxes,dbpath);
else
   error('not enough inputs')
end