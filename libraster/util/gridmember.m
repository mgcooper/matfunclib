function varargout = gridmember(X2, Y2, X1, Y1, GridOption)
%GRIDMEMBER find pixels in X2, Y2 that are members of X1, Y1
%
%  [LI2, LOC1] = GRIDMEMBER(X2, Y2, X1, Y1) returns indices of coordinate pairs
%  in X2, Y2 on X1, Y1. For analogy, consider [Lia, Locb] = ismember(A, B). The
%  2,1 convention used in gridmember is because X1, Y1 may often represent some
%  compact grid stored as grid vectors or geolocated coordinate lists, and X2,
%  Y2 represents a full-grid representation (or a grid-vector representation of
%  a coordinate-pair list). If the X1, Y1 grid points are geolocated but do not
%  represent a "full grid" there will be "missing pixels" i.e., pixels in X2, Y2
%  that are not in X1, Y1. If some other data call it V1 is referenced to X1,
%  Y1, the logical true/false LI2, and indices LOC1 are needed to adjust the
%  shape of V1 to match the new grid X2, Y2.
%
% Example
%
%
% Notes
% 
% LI2 is true for X2, Y2 pairs that exist in X1, Y1. LOC1 is the indices of the
% pairs in X2, Y2 that exist in X1, Y1, relative to X1, Y1, such that X2(LOC1),
% Y2(LOC1) LOC1, Missing pixels in X1, Y1 are therefore false in LI2.
% 
% Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper
%
% See also

%% main code

% Input checks
narginchk(4,5)

% Check grid formats
GridFormat1 = mapGridFormat(X1, Y1);
GridFormat2 = mapGridFormat(X2, Y2);

% Set default GridOption
if nargin < 5 || isempty(GridOption), GridOption = GridFormat2; end

% Keep the original shape of the target grid
xshape1 = num2cell(size(X1));
yshape1 = num2cell(size(Y1));
xshape2 = num2cell(size(X2));
yshape2 = num2cell(size(Y2));

% If either GridFormat1 or GridFormat2 is gridvector, convert to coordinates
if strcmp(GridFormat1, 'gridvectors')
   [X1, Y1] = fullgrid(X1, Y1); X1 = X1(:); Y1 = Y1(:);
end

if strcmp(GridFormat2, 'gridvectors')
   [X2, Y2] = fullgrid(X2, Y2); X2 = X2(:); Y2 = Y2(:);
end

% Find missing pixels. If gridvectors are converted to coordinates, then
% this works for all three GridFormats: fullgrids, gridvectors, coordinates
[LI2, LOC1] = ismember( ...
   unique([X2(:) Y2(:)], 'rows', 'stable'), ...
   unique([X1(:) Y1(:)], 'rows', 'stable'), 'rows');

% Reverse the ordering
[LI1, LOC2] = ismember( ...
   unique([X1(:) Y1(:)], 'rows', 'stable'), ...
   unique([X2(:) Y2(:)], 'rows', 'stable'), 'rows');

% % og method for reference:
% I = ~ismember( ...
%    unique([X2(:) Y2(:)], 'rows', 'stable'), ...
%    unique([X1(:) Y1(:)], 'rows', 'stable'), 'rows');
% 
% therefore, the og logical mapping is : I = ~LI2, e.g. try: isequal(I,~LI2)

% % Note: to get the missing coordinates:
% XY_missing = setdiff( ...
%    unique([X2(:) Y2(:)], 'rows', 'stable'), ...
%    unique([X1(:) X2(:)], 'rows', 'stable'), 'rows');

% But if GridOption is gridvecs, then we need to reshape back to gridvecs
if strcmp(GridOption, 'gridvectors')
   
   % NOTE: I think it's impossible to represent the missing pixels with gridvecs
   % because say 6,2 and 5,1 are missing but 6,1 is not, then how do we
   % designate this with gridvecs? The logical gridvecs produced here would be
   % false for x=5,6 and y = 1,2, which implies 6,1 is missing. This is more
   % trouble than it is worth.
   
   % might need 'stable' here too, also might get the LOC1X/Y and LOC2X/Y.
   
   % This seems to work in all cases. I added the LOC output, notice it is
   % relative to 2 not 1 since this is for mapping between the
   % coordinatepair/fullgrid representation of X2/Y2 and the gridvec. I am not
   % sure if the LOC has the same interpretation here as it does above.
   
   % What I am doing here is converting the LI2 representation as a coordinate
   % list to gridvector. 6,2 should be missing, which is X(3), Y(2), so LI2X
   % should be [1 1 0] and LI2Y should be [1; 0]
   
   [X, Y] = gridvec(X2, Y2);
   
   % Preserve this it is the original. It works if [LI2, LOC1] = ~ismember( ...
   % is used, which was the original method, to find missing pixels. Now we find
   % member pixesl, so we invert LI2 below in the indexing into X2 to find
   % missing pixels, then invert LI2X to find member pixesl.
   % [LI2X, LOC2X] = ismember(X, X2(LI2));
   % [LI2Y, LOC2Y] = ismember(Y, Y2(LI2));
   % these would need to go after the X1,Y1 gridvec conversion.
   % [LI1X, LOC1X] = ismember(X, X1(LI1));
   % [LI1Y, LOC1Y] = ismember(Y, Y1(LI1));
   
   % To get the LI2X/Y correct, invert them. 
   LI2X = ismember(X, X2(~LI2)); LI2X = ~LI2X;
   LI2Y = ismember(Y, Y2(~LI2)); LI2Y = ~LI2Y;
   
   % These LOC's are not verified. See the note above about this being a likely
   % waste of time, so I stopped here. The LI2X/Y are correct in principle, but
   % as noted above, will be misleading depending on the location of missing
   % pixels.
   [~, LOC2X] = ismember(X, X2(LI2));
   [~, LOC2Y] = ismember(X, X2(LI2));
   
   % above is og, added these to replicate for X1, Y1
   [X, Y] = gridvec(X1, Y1);
   LI1X = ismember(X, X1(~LI1)); LI1X = ~LI1X;
   LI1Y = ismember(Y, Y1(~LI1)); LI1Y = ~LI1Y;
   [~, LOC1X] = ismember(X, X1(LI1));
   [~, LOC1Y] = ismember(X, X1(LI1));
   
else
   % Send I back in the same shape as X2, Y2.
   LI2 = reshape(LI2, xshape2{:});
end

% Parse outputs
switch nargout

   case {0, 1} % coordinate lists or full grids
      
      if strcmp(GridOption, 'gridvectors')
         varargout{1} = LI2X;
      else
         varargout{1} = LI2;
      end
      
   case 2
      if strcmp(GridOption, 'gridvectors')
         varargout{1} = LI2X;
         varargout{2} = LI2Y;
      else
         varargout{1} = LI2;
         varargout{2} = LOC1;
      end
      
   case 4
      
      if strcmp(GridOption, 'gridvectors')
         varargout{1} = LI2X;
         varargout{2} = LI2Y;
      else
         varargout{1} = LI2;
         varargout{2} = LOC1;
         varargout{3} = LI1;
         varargout{4} = LOC2;
      end
      
end


%%
% This was an earlier method that used the input shape, keep for now.
% if strcmp(GridFormat2, 'gridvectors')
%
%    [r,c] = find(reshape(I, max(yshape{:}), max(xshape{:})));
%    IX = false(xshape{:});
%    IY = false(yshape{:});
%    IX(c) = true;
%    IY(r) = true;
%
% else
%
%    [X, Y] = gridvec(X2, Y2);
%    IX = ismember(X, X2(I));
%    IY = ismember(Y, Y2(I));
% end
   
%%
% % It doesn't work to make Grid1 match Grid2 b/c conversion to fullgrids or
% % gridvecs fills in the missing pixels ... the only issue is when gridvecs are
% % supplied b/c they can be different size in the x-y, whereas fullgrids and
% % coordinatelists both have the same number, so the original ismember method
% % works for both.
% 
% % Make both Grid1 and Grid2 coordinates
% if ~strcmp(GridFormat1, GridFormat2)
% 
%    switch GridFormat2
% 
%       case 'gridvectors'
%          [X1, Y1] = gridvec(X1, Y1);
% 
%       case 'fullgrids'
%          [X1, Y1] = fullgrid(X1, Y1);
% 
%       case 'coordinates'
% 
%          [X1, Y1] = fullgrid(X1, Y1);
%          X1 = X1(:); Y1 = Y1(:);
%    end
% end

end


%% local functions


%% LICENSE

% BSD 3-Clause License
%
% Copyright (c) YYYY, Matt Cooper (mgcooper)
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.