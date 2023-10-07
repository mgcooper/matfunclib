function vars = h5vars(fname)
   %NCVARS Extract the variable names in an h5 file
   %   
   % vars = h5vars(fname)
   %
   % See also: 

   Info = h5info(fname);
   vars = {Info.Groups.Name}';
end
