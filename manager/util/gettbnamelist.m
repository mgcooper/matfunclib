function namelist = gettbnamelist
   %GETTBNAMELIST get a list of toolbox names in the toolbox directory
   %
   %  namelist = gettbnamelist() returns a list of toolbox names in the directory
   %
   % See also: gettbdirectorylist

   tbdirectory = readtbdirectory;
   namelist = tbdirectory.name;
end
