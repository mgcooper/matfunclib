function gridFormat = mapGridFormat(X, Y)
%MAPGRIDFORMAT determine if grid format is fullgrid, gridvectors, or coordinates
% 
% 
%
% 
% 
% See also mapGridInfo mapGridCellSize prepareMapGrid

% Require X and Y be numeric and non-empty
validateGridCoordinates(X, Y, mfilename)

% Convert sparse to full
X = full(X);
Y = full(Y);

% Determine grid format. Check for fullgrids must come after check for
% gridvectors/coordinates, since matrices are also vectors.
if isscalar(X) && isscalar(Y)
   gridFormat = "point";
elseif isvector(X) && isvector(Y)
   
   % If X and Y have the same number of elements, they are coordinate pairs,
   % unless they have no repeat elements, in which case they are gridvectors. If
   % they are coordinate pairs with the same number of elements and no unique
   % elements, then they are effectively grid vectors.
   if numel(X) == numel(Y)
      if numel(unique(X)) == numel(X) && numel(unique(Y)) == numel(Y)
         gridFormat = "gridvectors";
      else
         gridFormat = "coordinates";
      end
   else
      gridFormat = "gridvectors";
   end
   
   % I think above could be simplified to:
   
   % if numel(unique(X)) == numel(X) && numel(unique(Y)) == numel(Y)
   %    gridFormat = "gridvectors";
   % elseif numel(X) == numel(Y)
   %    gridFormat = "coordinates";
   % else
   %    gridFormat = "unrecognized";
   % end
   
elseif ismatrix(X) && ismatrix(Y) && all(size(X) == size(Y))
   gridFormat = "fullgrids";
else
   gridFormat = "unrecognized";
end

% If coordinate pairs, confirm nan elements are equal
if gridFormat == "coordinates"
   assert(isequal(isnan(X), isnan(Y)), ...
      'NaN elements do not match in coordinate pairs' , mfilename, 'X', 'Y')
end

end


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