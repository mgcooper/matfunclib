function data = ncreaddata(fname,varargin)
   %NCREADDATA Read all data in .nc file fname, or all vars in optional list
   %
   %  data = ncreaddata(fname) reads all variables in fname
   %  data = ncreaddata(fname,vars) reads variables vars in fname
   %
   % Required inputs:
   %
   %  fname - full path to .nc file
   %
   % Optional inputs:
   %
   %  varnames - cellstr array of chars that match the variable names in the
   %  .nc file to read. Default behavior reads all variables.
   %
   % Note: the data is converted to column major format
   %
   % See also: ncparse

   finfo = ncparse(fname);
   if nargin == 1
      vars = finfo.Name;
      % was gonna have a flag or something to note that i can use ncparse
      % output since it matches vars inptu
      % if height(finfo) ~= numel(vars)
      % end
   else
      vars = varargin{1};
   end

   data.info = finfo;

   for n = 1:length(vars)

      data_n = ncread(fname,vars{n});
      info_n = ncinfo(fname,vars{n});

      % try to determine if variable is a 2-d or 3-d spatial variable and if
      % so, rotate so it's orientied correctly
      if info_n.Size > 1
         data_n = rot90(fliplr(data_n));
      end
      data.(vars{n}) = data_n;

      % here I was gonna compare the ncinfo output to a few cases where I know I
      % wouldn't want to rotate the data
      %     % first deal with known cases
      %     if ismember({info_n.Attributes.Name},'time')
      %         data.(vars{n}) = data_n;
      %     end

      % here I was gonna do the same thing but use my ncparse output
      %     % check against my ncparse function
      %     if strcmp(info_n.Name,finfo.Name(n))
      %         if finfo.Size(n)
      %         end
      %     else
   end
end
