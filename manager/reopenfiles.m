function reopenfiles(filelist)

for n = 1:numel(filelist)
   thisfile = filelist(n);
   try
      open(thisfile)
   catch
      % strip out the path
      [~,fname,ext] = fileparts(thisfile);
      fname = [char(fname), char(ext)];
      tryfile = which(fname);
      try
         open(tryfile)
      catch
         % let it go
      end
   end
end