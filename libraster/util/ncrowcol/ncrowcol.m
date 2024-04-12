function [start, count] = ncrowcol(ncvar, ncX, ncY, xpoly, ypoly, varargin)
%NCROWCOL find start and count indices for netcdf file
% 
% [start, count] = ncrowcol(ncvar, ncX, ncY, xpoly, ypoly)
%
% See also

% NOTE: very easy to forget that ncvar is only used to determine the
% size of the 3rd and 4th dimension if they exist, so the orientation
% of ncvar has no impact on the returned start,count row/col indices,
% those are determined by finding the points inside the polygon

% this currently accepts a variable ncvar that is already in the
% workspace, but I want it to accept the name of a variable within the
% nc file so it can query that file to determine the

varIsChar = false; % assume a data var was provided rather than char variable name
if ischar(ncvar)
   info = varargin{1};
   ivar = ismember(info.Name,ncvar);
   varsize = info.Size{ivar};
   varIsChar = true;
end

% % check if input is geographic or projected
% if islatlon(ncY,ncX)
% end

% check if polygon is provided or just a point
if numel(xpoly) > 1
   inpoly  =   inpolygon(ncX,ncY,xpoly,ypoly);
   [r,c]   =   ind2sub(size(inpoly),find(inpoly));
   r       =   unique(r);
   c       =   unique(c);
else % use dsearchn
   knear   =   dsearchn([ncX(:) ncY(:)],[xpoly ypoly]);
   [r,c]   =   ind2sub(size(ncX),knear);
   r       =   unique(r);
   c       =   unique(c);
   % note: to support multiple nearby neighbors, use findnearby, but
   % that will require more complicated input checks
end

% NOTE: based on ncrowcol_mar, it might be necessary to use unique(r)
% and then

% previously I used this for the count, but it is wrong when there is a missing
% value in the rows or columns i.e. when all(diff(r) == 1) is not true
rowcount = @(r) max(r)-min(r)+1; % rowcount = @(r) length(unique(r));
colcount = @(c) max(c)-min(c)+1; % colcount = @(c) length(unique(c));

if varIsChar == false
   if iscolumn(ncvar)
      start = r(1);
      count = rowcount(r);
   elseif isrow(ncvar)
      start = c(1);
      count = colcount(c);
   elseif ismatrix(ncvar)
      start = [r(1),c(1)];
      count = [rowcount(r), colcount(c)];
   elseif ndims(ncvar)==3
      start = [r(1),c(1),1];
      count = [rowcount(r),colcount(c),size(ncvar,3)];
   elseif ndims(ncvar)==4
      start = [r(1),c(1),1,1];
      count = [rowcount(r),colcount(c),size(ncvar,3),size(ncvar,4)];
   else
      warning('This function does not support 4-d or higher dimension variables');
   end

else
   disp(['warning: row/col indexing may be unreliable for 1-d vars ' ...
      newline 'if variable name is provided instead of variable']);

   if numel(varsize) == 1
      start = r(1);
      count = rowcount(r);
   elseif numel(varsize) == 2
      start = [r(1),c(1)];
      count = [rowcount(r),colcount(c)];
   elseif numel(varsize) == 3
      start = [r(1),c(1),1];
      count = [rowcount(r),colcount(c),varsize(3)];
   elseif numel(varsize) == 4
      start = [r(1),c(1),1,1];
      count = [rowcount(r),colcount(c),varsize(3),varsize(4)];
   else
      warning('This function does not support 4-d or higher dimension variables');
   end
end

% rowcol.ncstart_1d_row   =   r(1);
% rowcol.ncstart_1d_col   =   c(1);
% rowcol.ncstart_2d       =   [r(1),c(1)];
% rowcol.ncstart_3d       =   [r(1),c(1),1];
% rowcol.nccount_1d_row   =   length(unique(r));
% rowcol.nccount_1d_col   =   length(unique(c));
% rowcol.nccount_2d       =   [length(unique(r)),length(unique(c))];
% rowcol.nccount_3d       =   [length(unique(r)),length(unique(c)),size(ncvar,3)];
% 
% rowcol.msg = {'the third value in ncstart3d is set nan. It needs to ' ...
%    'be set to the first index of the third dimension. ' ...
%    'If the third dimension is time, then setting it to 1 ' ...
%    'would mean '};


% DEBUGGING - this was in the if numel(xpoly) > 1 section, it came up when I got
% fewer x,y points when using start,count from this function than I did when I
% read in the full lat, lon grids from the .nc file and used inpolygon to get
% the points inside the polygon. The real issue was that the polygon needs to be
% buffered (lesson learned in interpolationPoints), but fortunately it also
% inadvertently revealed that if the r, c points found somehow miss a value for
% example normally rows might be 1,2,3,4 but sometimes it skips a value e.g.
% 1,3,4, in which case 

% r,c and R,C, contain the same unique points
% [R, C] = fullgrid(r, c);
% figure;
% scatter(R(:), C(:), 'filled'); hold on;
% scatter(r(:), c(:), 'filled');

% the x,y points plotted here cover more of the polygon than the x,y points
% extracted from the nc file using start, count, so something must be going
% wrong ... figured it out, see notes above.
% figure;
% scatter(ncX(inpoly), ncY(inpoly), 'filled'); hold on;
% plot(xpoly, ypoly)
   
end

