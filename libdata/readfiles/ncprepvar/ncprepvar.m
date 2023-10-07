function data = ncprepvar(data, ndims, dimorder)
   %NCPREPVAR prepare variable for writing to netcdf

   % This function was intended to deal with conversion b/w row-major and
   % column-major and different interpretations of the size of an array (i.e.,
   % matlab doesn't have 'lists' with one dimension, all arrays are matrices with
   % vectors being size Nx1 or 1xM. I abandoned this once i figured out that it
   % isn't necessary to make the fake dimension (1 in the example below) which
   % might require using the unlimited dimension (see save_icemodel_nc.m)

   if numel(ndims) == 2
      dtmp = nan(ndims(1),ndims(2));
   elseif numel(ndims) == 3
      dtmp = nan(ndims(1),ndims(2),ndims(3));
   end
   dtmp = nan(1,nlyrs,nhrs);

   for q = 1:nhrs
      dtmp(1,:,q) = data(:,q);
   end
   data = dtmp;
end
