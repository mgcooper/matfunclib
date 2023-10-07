function reopenfiles(filelist)
   %REOPENFILES Reopen files in filelist
   %
   %
   % See also

   % UPDATES
   % 10Mar2023 if filelist is a cell array use brace indexing, if filelist is a
   % char assume its one filename and break after the first iteration

   % this would work for versions with 'string' type
   % if iscell(filelist)
   %    filelist = string(filelist);
   % end
   waschar = false;

   for n = 1:numel(filelist)

      if iscell(filelist)
         thisfile = filelist{n};
      elseif ischar(filelist)
         waschar = true;
      else
         thisfile = filelist(n);
      end

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

      % if filelist was a char, assume it was one file and stop here
      if waschar
         break
      end
   end
end
