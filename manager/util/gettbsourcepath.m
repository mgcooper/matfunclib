function tbpath = gettbsourcepath(tbname)
   %GETTBSOURCEPATH Get full path to toolbox source directory.
   if nargin == 0
      tbpath = getenv('MATLABSOURCEPATH');
   elseif nargin == 1
      tbdirectory = readtbdirectory();
      tbpath = char(tbdirectory.source(findtbentry(tbdirectory, tbname)));
      tbpath = rmtrailingslash(tbpath);
   end
end

function pathstr = rmtrailingslash(pathstr)
   if strcmp(pathstr(end),'/')
      pathstr = pathstr(1:end-1);
   end
end
