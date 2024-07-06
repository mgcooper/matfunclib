function varargout = validateRasterReference(V, R, funcname, varargin)
   %VALIDATERASTERREFERENCE Validate raster reference object R and grid data V.
   %
   %  [V,R] = VALIDATERASTERREFERENCE(V,R) description
   %
   % See also: validateGridCoordinates, validateGridData

   % Input parsing
   narginchk(0,Inf)
   [varargin{:}] = convertStringsToChars(varargin{:});
   if nargin < 3 || isempty(funcname); funcname = mcallername(); end

   if nargin == 4
      CoordinateSystemType = varargin{1};
   else
      CoordinateSystemType = 'unspecified';
   end

   % Main function
   switch CoordinateSystemType
      case 'geographic'
         validateattributes(R, ...
            {'map.rasterref.GeographicCellsReference', ...
            'map.rasterref.GeographicPostingsReference'}, ...
            {'scalar'}, funcname, 'R')

      case 'planar'
         validateattributes(R, ...
            {'map.rasterref.MapCellsReference', ...
            'map.rasterref.MapPostingsReference'}, ...
            {'scalar'}, funcname, 'R')

      otherwise
         validateattributes(R, ...
            {'map.rasterref.MapCellsReference', ...
            'map.rasterref.GeographicCellsReference', ...
            'map.rasterref.MapPostingsReference', ...
            'map.rasterref.GeographicPostingsReference'}, ...
            {'scalar'}, funcname, 'R')
   end

   if ~isempty(V)
      validateattributes(V, {'numeric', 'logical'}, ...
         {'size', [R.RasterSize, size(V, 3)]}, funcname, 'V');
   end

   switch nargout
      case 0
      case 1
         varargout{1} = V;
      case 2
         varargout{1} = V;
         varargout{2} = R;
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
