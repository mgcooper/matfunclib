function TF = isRasterReference(R, varargin)
%ISRASTERREFERENCE return true if R is a rasterref object
%
%  TF = ISRASTERREFERENCE(R)
%  TF = ISRASTERREFERENCE(R, 'geographic')
%  TF = ISRASTERREFERENCE(R, 'planar')
%  TF = ISRASTERREFERENCE(_, 'all')
%  TF = ISRASTERREFERENCE(_, 'any')
%  TF = ISRASTERREFERENCE(_, 'each')
%
%  R can be a scalar rasterref object or a cell array of R objects.
% 
% Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper
%
% See also validateRasterReference

%% input checks
narginchk(1,3)

[varargin{:}] = convertStringsToChars(varargin{:});

[option, args, nargs] = parseoptarg(varargin, {'each', 'any', 'all'}, 'all');

if nargs == 1
   CoordinateSystemType = args{1};
else
   CoordinateSystemType = 'unspecified';
end

if isscalar(R)
   R = num2cell(R);
else
   % validateattributes(R, {'cell'}, {'nonempty'}, mfilename, 'R', 1);
   if ~iscell(R)
      TF = false;
      return
   end
end

%% main code

for n = 1:numel(R)
   
   switch CoordinateSystemType
      case 'geographic'
         TF(n) = ...
            isa(R{n}, 'map.rasterref.GeographicCellsReference') | ...
            isa(R{n}, 'map.rasterref.GeographicPostingsReference');
   
      case 'planar'
         TF(n) = ...
            isa(R{n}, 'map.rasterref.MapCellsReference') | ...
            isa(R{n}, 'map.rasterref.MapPostingsReference');
   
      otherwise
         TF(n) = ...
            isa(R{n}, 'map.rasterref.GeographicCellsReference') | ...
            isa(R{n}, 'map.rasterref.GeographicPostingsReference') | ...
            isa(R{n}, 'map.rasterref.MapCellsReference') | ...
            isa(R{n}, 'map.rasterref.MapPostingsReference');
   end
end

% Unless each is requested, assume the test is on all of them
switch option
   case 'all'
      TF = all(TF);
   case 'any'
      TF = any(TF);
   case 'each'
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