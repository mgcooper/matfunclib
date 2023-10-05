function n = linecount(filename)
   %LINECOUNT count the # of lines in a text file
   %
   % n = linecount(filename)
   %
   % See also: fgetl

   warning('dont use this to preallocate, instead over-allocate a ')

   [fid, msg] = fopen(filename);
   if fid < 0
      error('Failed to open file "%s" because "%s"', filename, msg);
   end

   n = 0;
   while true
      t = fgetl(fid);
      if ~ischar(t)
         break;
      else
         n = n + 1;
      end
   end
   fclose(fid);
end
