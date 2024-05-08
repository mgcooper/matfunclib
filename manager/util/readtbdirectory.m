function toolboxes = readtbdirectory(dbpath)
   if nargin<1
      dbpath = gettbdirectorypath;
   end
   toolboxes = readtable(dbpath,'Delimiter',',','ReadVariableNames',true);
   % This converts nan to missing
   toolboxes.library = string(toolboxes.library);
end
