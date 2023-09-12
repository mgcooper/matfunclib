function varargout = mapGridOutline(X, Y, dX, dY, varargin)
   %MAPGRIDOUTLINE create a polygon representing the outline of a map grid
   %
   %  P = MAPGRIDOUTLINE(X, Y) returns polyshape P corresponding to the outline
   %  (grid frame) of the regular grid defined by coordinates X and Y. The cell
   %  spacing is inferred from the X, Y data, and is used to extend the grid
   %  frame 1/2 cell size in each direction from the min/max X/Y coordinates.
   %
   %  P = MAPGRIDOUTLINE(X, Y, dX, dY) uses dX and dY for the cell spacing.
   %
   %  [PX, PY] = MAPGRIDOUTLINE(X, Y) returns polygon vertices PX, PY.
   %
   %  [PX, PY, P] = MAPGRIDOUTLINE(X, Y) also returns a polyshape P.
   %
   % See also: mapbox, geobox

   % input checks
   narginchk(2,Inf)

   % simplest input parsing
   if (nargin<3), [~, dX, dY] = mapGridInfo(X, Y); end
   if (nargin==3), dY = dX; end

   % create the outline
   [varargout{1:nargout}] = mapbox( ...
      [min(X(:))-dX/2 max(X(:))+dX/2], [min(Y(:))-dY/2 max(Y(:))+dY/2]);
end

%% LICENSE

% BSD 3-Clause License
%
% Copyright (c) 2023, Matt Cooper (mgcooper)
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
