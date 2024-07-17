function [V, X, Y] = validateGridData(V, X, Y, funcname, argname1, ...
      argname2, argname3, outputFormat)
   %VALIDATEGRIDDATA Validate gridded data for function inputs.
   %
   % [V, X, Y] = validateGridData(V, X, Y, funcname, argname1, ...
   %    argname2, argname3, outputFormat)
   %
   % This function does not require V, X, Y to be fullgrids, but it does require
   % the number of elements in X and Y to match the number of elements in EITHER
   % the first OR the first two dimensions of V. By default, V, X, and Y are
   % returned in the same size they are sent in. If OUTPUTFORMAT='coordinates',
   % X and Y are returned as 1d lists of coordinate pairs, and V is returned as
   % a 1d list or 2d array where its 1st dimension matches the size of X and Y.
   % If OUTPUTFORMAT='gridvectors', then X and Y are returned as gridvectors and
   % V is returned in the size it was sent in. If OUTPUTFORMAT='fullgrids', X,
   % Y, and V are returned in fullgrid format, in a manner analogous to the
   % coordinate pair option.
   %
   % See also xyzchk

   if nargin < 4 || isempty(funcname); funcname = mcallername(); end
   if nargin < 5 || isempty(argname1); argname1 = 'X'; end
   if nargin < 6 || isempty(argname2); argname2 = 'Y'; end
   if nargin < 7 || isempty(argname3); argname3 = 'V'; end

   inputFormat = mapGridFormat(X, Y);

   if nargin < 8 || isempty(outputFormat)
      outputFormat = inputFormat;
   end

   validateGridFormat(outputFormat);
   validateGridCoordinates(X, Y, funcname, 'X', 'Y', inputFormat);
   validateattributes(V, {'numeric', 'logical'}, {'3d'}, funcname, 'V');

   % If using R
   % validateattributes(V, {'numeric', 'logical'}, {'size', R.RasterSize}, ...
   %    funcname, 'V', 3)

   % Jul 2024: With V a full grid and X and Y gridvectors, the method below
   % failed. The logic behind "size(V) must be [numel(X), numsamples]" must
   % apply to coordinates and full grids. So I added this:
   if strcmp('gridvectors', inputFormat)
      [X, Y] = fullgrid(X, Y);
   end

   [inputSizeX, inputSizeY, inputSizeV] = deal(size(X), size(Y), size(V));

   % Convert X and Y to columns and ensure the first two dims of V match X,Y.
   X = X(:);
   Y = Y(:);
   switch ndims(V)
      case 3
         V = reshape(V, size(V, 1) * size(V, 2), []);
      case 2
         if numel(X) == numel(V)
            V = V(:);
         end
      otherwise
         % size(V) must be: [numel(X), numsamples] where: numel(X)=numel(Y),
         % and numsamples could be numtimesteps etc.
   end

   % This will catch the case where size(V) is not [numel(X), numsamples]
   assert( numel(X) == size(V, 1), ...
      sprintf('custom:%s:inconsistentXYV', funcname), ...
      ['Function %s expected the first two dimensions of input argument ' ...
      'V to match X and Y in size.'], upper(funcname))

   % Return the data as requested or in its input size.
   switch outputFormat

      case 'gridvectors'
         [X, Y] = gridvec(X, Y);
         V = reshape(V, inputSizeV);

      case 'fullgrids'
         [X, Y] = fullgrid(X, Y);
         V = reshape(V, size(X, 1), size(X, 2), []);

      case 'coordinates'
         % nothing required

      otherwise
         X = reshape(X, inputSizeX);
         Y = reshape(Y, inputSizeY);
         V = reshape(V, inputSizeV);
   end
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
