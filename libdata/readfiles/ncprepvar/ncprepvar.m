function data = ncprepvar(data,ndims,dimorder)

%    i abandoned this once i figured out that it isn't necessary to make
%    the fake dimension (1 in the example below) which might require using
%    the unlimited dimension, see save_icemodel_nc.m
   
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