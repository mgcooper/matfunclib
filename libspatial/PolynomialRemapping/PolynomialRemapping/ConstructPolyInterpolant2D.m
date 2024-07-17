function P=ConstructPolyInterpolant2D(xs,ys,xd,yd,nPoly,nInterp)
% ConstructPolyInterpolant2D (ConstructProjector2D)
% Description: constructs an interpolant/extrapolant to project data from
% the source grid onto the destination grid. Uses polynomial formula for
% interpolation.
% Inputs:
%   - xs,ys: source grid coordinates. They could be of any dimensionality
%   (usually 2-dimensional array for structured grid and 1-dimensional for
%   unstructured or scaterred grid. xs and ys must have the same dimension
%   though.
%   - xd,yd: destination grid. They could be of any dimensionality
%   (usually 2-dimensional array for structured grid and 1-dimensional for
%   unstructured or scaterred grid. xd and yd must have the same dimension
%   though.
%   - nPoly: degree of polynomial to use.
%   - nInterp: 
%     * if nInterp<0 and is a scalar, it is number of points to use to 
%       calculate the coefficients. 
%                 (nPoly+1)^2 <= nInterp <= numel(xs)
%       The code looks for nInterp closest point on source grid for each 
%       point of the destination grid. It adjusts the number of points
%       being used by looking what was the farthest distance. For example,
%       if one provides -10 as nInterp, the code looks for 10 closest
%       point and ranks their distance. Then it selects everypoint within
%       the distance of d(10), where d(10) is the distance ranked 10.
%       if nInterp>0 and is an scalar, its value is treated as distance.
%       for example, if nInterp=2.3 then the code looks and searches for
%       every point within 2.3 radius and uses them all to construct the
%       interpolant. If there are not enough points within that distance
%       the user is warned and the distance is increased automatically.
%     * if nInterp is a matrix, then it must be Ndx1. This allows to
%       provide a separate nInterp for each point of the destination grid.
%       NOTE: The same rule as in above case applies, i.e. if nInterp(i) is
%       negative it signals the number of point to use for i-th point of 
%       the destination grid and if it is positive it is treated as a
%       maximum distance.
%     * if nInterp is a cell array, it must be of size Ndx1 and each 
%       element of nInterp, i.e. nInterp{i} must be an array of Nx1 storing 
%       the index of N point on source grid that must be used to determine 
%       the coefficients (N can vary for each cell). This fixes the points 
%       on source grid that must be used to interpolate. So, instead of
%       chosing the points based on their distance, the user can define
%       exactly what points to use. This is usefull in cases that the user
%       has another criteria or algorithm in choosing the points.
%
% Output:
%   - P: projector. P is a sparse matrix. To get data on the destination
%   grid multiply P by the data on source grid. Data on source grid must be
%   stored in a vector and the resulting data on the destination grid must
%   be reshaped into desired dimension. Refer to Test*.m to see how to do
%   it.
%
% NOTE: The code uses parfor; however, if a matlab pool is not launched the
%       code would not manually launches a matlab pool. To benefit from
%       MATLAB's Paralel Processing Toolbox, launch the pool manually.

%%
% Copyright (c) 2013, Mohammad Abouali (maboualiedu@gmail.com)
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

%% Checking nPoly
validateattributes(nPoly,{'numeric'},{'scalar'});

if (round(nPoly)~=nPoly || nPoly<=0)
  error('nPoly must be a positive integer number');
end

%% Getting the dimension of the projector/interpolator
Ns=numel(xs);
Nd=numel(xd);
nCoef=(nPoly+1)^2;

%% Checking for errors.
if (any(size(xs)~=size(ys)))
  error('ConstructProjector2D : xs and ys must have the same size.');
end
if (any(size(xd)~=size(yd)))
  error('ConstructProjector2D : xd and yd must have the same size.');
end

%% Checking if neighborhood matrix is available
if (isscalar(nInterp))
  NHoodMatrixAvailable=false;
  isGlobal= nInterp==0;
  if (isGlobal)
    error('nInterp cannot be zero.');
  end
elseif (iscell(nInterp))
  isGlobal=false;
  NHoodMatrixAvailable=true;
  if (numel(nInterp)~=Nd)
    error(['ConstructProjector2D : once nInterp is cell array it must ' ...
           'have Nd elements. where Nd is the number of points in ' ...
           'destination grid.']);
  end
elseif (ismatrix(nInterp))
  isGlobal=false;
  NHoodMatrixAvailable=false;
  if (size(nInterp,2)~=1 || size(nInterp,1)~=Nd)
    error(['ConstructProjector2D : once nInterp is a matrix, it must be ' ...
           'of size Ndx1, where Nd is the number of points in the ' ...
           'destination grid.']);
  end
else
  error('ConstructProjector2D : nInterp must be either an integer scalar, matrix or a cell array.')
end

%% Checking to make sure a valid number is provided in nInterp. 
if (NHoodMatrixAvailable==false)
  if (any( (-nInterp)<nCoef & nInterp<0 ))
    error(['nInterp must be bigger than or equal to ' num2str(nCoef) '.']);
  end
  if (any((-nInterp)>Ns & nInterp<0))
    error('nInterp is trying to index more points that are in source grid.');
  end
else
  if (any(cellfun(@(x) numel(x)<nCoef,nInterp)))
    error(['There must be at least ' num2str(nCoef) ' points ', ...
           'defined for each destination point in nInterp']);
  end
  if (any(cellfun(@(x) any(x>Ns),nInterp)))
    error('nInterp is trying to index more points that are in source grid.');
  end
end

%% Converting to a vector
xs=xs(:);
ys=ys(:);
xd=xd(:);
yd=yd(:);

%% Initializing and reserving memory
SparseIndex_i=cell(Nd,1);
SparseIndex_j=cell(Nd,1);
P_nonZeroElem=cell(Nd,1);

[i1,i2]=ndgrid(0:nPoly);
i1=reshape(i1,1,[]);
i2=reshape(i2,1,[]);

%% Adjusting nInterp (mainly for parellel loop)
if (NHoodMatrixAvailable==false && ~isGlobal)
  if (isscalar(nInterp))
    nInterp=num2cell( nInterp*ones(Nd,1) );
  else
    nInterp=num2cell( nInterp );
  end
end

%% Looping over each point on destination grid.
% Making sure that a matlab pool is not going to be launched.
% NOTE: if you want this code to run in parallel, the matlab pool needs to
%       be launched manually prior to calling this function.
ps = parallel.Settings;
AutoCreateOriginalStatus=ps.Pool.AutoCreate;
ps.Pool.AutoCreate = false;

parfor i=1:Nd
  subXs=0;  % Just to get read of a nasty warning that MATLAB generates.
  subYs=0;
  i1Matrix=0;
  i2Matrix=0;
  
  if (NHoodMatrixAvailable==true)
    % neighborhood matrix is provided.
    % use those points to interpolate.
    nPointInNHood=numel(nInterp{i})
    SparseIndex_i{i}=ones(nPointInNHood,1)*i;
    SparseIndex_j{i}=reshape(nInterp{i},[],1);

    subXs=xs(nInterp{i}(:)); %#ok<*PFBNS>
    subYs=ys(nInterp{i}(:));

    i1Matrix=repmat(i1,nPointInNHood,1);
    i2Matrix=repmat(i2,nPointInNHood,1);

  else
    if nInterp{i}<0 % nInterp is the number of points.
      % no neighborhood matrix is provided.
      % looking for nInterp closest point.
      d=((xs-xd(i)).^2+(ys-yd(i)).^2).^(0.5);
      d_sorted=sort(d,'ascend');
      SparseIndex_j{i}=find( d <= d_sorted(-nInterp{i}) )
      SparseIndex_i{i}=ones(numel(SparseIndex_j{i}),1)*i;

      subXs=xs(SparseIndex_j{i});
      subYs=ys(SparseIndex_j{i});

      i1Matrix=repmat(i1,numel(SparseIndex_j{i}),1);
      i2Matrix=repmat(i2,numel(SparseIndex_j{i}),1);
    elseif nInterp{i}>0 % nInterp is the distance
      d=((xs-xd(i)).^2+(ys-yd(i)).^2).^(0.5);
      SparseIndex_j{i}=find( d <= nInterp{i} )
      if ( numel(SparseIndex_j{i})<nCoef )
        warning(['Destination point: ' num2str(i) '. ' ...
                 'Could not find enough point within the provided radius. ' ...
                 'Increasing the radius.']);
        d_sorted=sort(d,'ascend');
        SparseIndex_j{i}=find( d <= d_sorted(nCoef) );
      end
      SparseIndex_i{i}=ones(numel(SparseIndex_j{i}),1)*i;

      subXs=xs(SparseIndex_j{i});
      subYs=ys(SparseIndex_j{i});

      i1Matrix=repmat(i1,numel(SparseIndex_j{i}),1);
      i2Matrix=repmat(i2,numel(SparseIndex_j{i}),1);
    else
      error('nInterp can not have an element with zero value.');
    end
  end

  % Scaling the X and Y to lower the matrix condition numbers.
  avgSubXs=mean(subXs);
  avgSubYs=mean(subYs);

  subXs_avg=subXs-avgSubXs;
  subYs_avg=subYs-avgSubYs;

  ScaleSubXs=max(abs(subXs_avg));
  ScaleSubYs=max(abs(subYs_avg));

  scale=max( [ScaleSubXs,ScaleSubYs] );
  subXs=subXs_avg./scale;
  subYs=subYs_avg./scale;

  % Preparing the matrix for inversion
  tmp1=repmat(subXs,1,nCoef).^i1Matrix ...
       .* repmat(subYs,1,nCoef).^i2Matrix;

  % x^iy^j i,j \in 0:nPoly for the destination point
  tmp2= ((xd(i)-avgSubXs)./scale).^i1 .* ((yd(i)-avgSubYs)./scale).^i2;

  % Coefficients that interpolates/extrapolates to the destination grid.
  P_nonZeroElem{i}=transpose( tmp2* ((tmp1'*tmp1)\tmp1') );
end

%%
SparseIndex_i=cell2mat(SparseIndex_i);
SparseIndex_j=cell2mat(SparseIndex_j);
P_nonZeroElem=cell2mat(P_nonZeroElem);

P=sparse(SparseIndex_i,SparseIndex_j,P_nonZeroElem,Nd,Ns);

%% Reverting back AutoCreate Status to whatever it was.
ps.Pool.AutoCreate = AutoCreateOriginalStatus;

end
