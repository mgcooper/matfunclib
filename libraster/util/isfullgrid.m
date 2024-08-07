function tf = isfullgrid(X, Y, varargin)
   %ISFULLGRID Determine if X and Y are full grids.
   %
   %  TF = ISFULLGRID(X, Y) returns TRUE if the coordinates in X, Y contain all
   %  elements of their fullgrid representation and FALSE otherwise. X, Y can be
   %  coordinate-pair lists or gridvectors.
   %
   %  TF = ISFULLGRID(X, Y, GRIDFORMAT) Uses specified GRIDFORMAT to test if
   %  X, Y are fullgrids. GRIDFORMAT can be "coordinates" or "gridvectors". If
   %  GRIDFORMAT is not provided, it is computed. Specify GRIDFORMAT to save the
   %  computation.
   %
   % Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, github.com/mgcooper
   %
   % See also: fullgrid, gridmember

   % input checks
   narginchk(2, Inf)

   if nargin < 3
      gridFormat = mapGridFormat(X, Y);
   else
      gridFormat = varargin{1};
   end

   if gridFormat == "gridvectors"

      [X2, Y2] = fullgrid(X, Y);
      tf = all(gridmember(X2, Y2, X, Y), 'all');

      % % Update: Not sure how this could have "worked" since X and Y have
      % different number of elements.
      % % This works if X, Y are gridvectors
      % tf = all(ismember( ...
      %    [X(:), Y(:)], ...
      %    [xfullgrid(X, Y, 'coordinates'), yfullgrid(X, Y, 'coordinates')], ...
      %    'rows'));

   else
      % This will fail if X, Y are gridvectors
      tf = all(ismember( ...
         [xfullgrid(X, Y, 'coordinates'), yfullgrid(X, Y, 'coordinates')], ...
         [X(:), Y(:)], 'rows'));
   end

   % "unique" should not be necessary, but keep this around for now:
   % tf = all(ismember(unique( ...
   %    [xfullgrid(X, Y, 'coordinates'), yfullgrid(X, Y, 'coordinates')], ...
   %    'rows'), unique([X(:), Y(:)], 'rows'), 'rows'));
end

%% notes

% If for some reason the method above fails, this should work:
% [X2, Y2] = fullgrid(X, Y);
% tf = all(gridmember(X2, Y2, X, Y), 'all');

% This confirms that xfullgrid produces the correct values
% isequal(X2(:), xfullgrid(X, Y, 'coordinates'))
% isequal(Y2(:), yfullgrid(X, Y, 'coordinates'))

% NOTE, this is necessary but not sufficient:
% tf = numel(xgridvec(X)) * numel(ygridvec(Y)) == numel(fullgrid(X, Y));

%% LICENSE

% BSD 3-Clause License
%
% Copyright (c) 2023, Matt Cooper (mgcooper) All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice, this
% list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its contributors
% may be used to endorse or promote products derived from this software without
% specific prior written permission.
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
