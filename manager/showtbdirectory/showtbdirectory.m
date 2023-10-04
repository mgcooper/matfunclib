function tbdir = showtbdirectory()
   %SHOWTBDIRECTORY
   %
   % tbdir = showtbdirectory() returns the directory and prints it to the console
   %
   % See also: lstoolboxes, lstbdirectory

   dbpath = gettbdirectorypath;
   tbdir = readtbdirectory(dbpath);
   disp(tbdir)
end
