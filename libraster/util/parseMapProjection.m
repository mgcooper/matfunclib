function mapProj = parseMapProjection(isgeo, varargin)
%PARSEMAPPROJECTION general description of function
%
%  MAPPROJ = PARSEMAPPROJECTION(ISGEO,WKTSTRING) converts WKTSTRING to geocrs
%  object if ISGEO is true, otherwise to projcrs object.
%  MAPPROJ = PARSEMAPPROJECTION(ISGEO, PROJCODE, AUTHORITY) creates a geocrs 
%  object if ISGEO is true, otherwise a projcrs object using the numeric scalar
%  projection code PROJCODE and provided authority, indicated by char or string
%  AUTHORITY.
%
% Example
%
%
%
% Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper
%
% See also bbox2R

%% main code

% input checks
narginchk(2,3)

% Not sure if this is needed
% [varargin{:}] = convertStringsToChars(varargin{:});

funcname = mcallername();

if nargin == 2

   mapProj = varargin{1};
   
    validateattributes(mapProj, {'projcrs', 'geocrs', 'char', 'string'}, ...
      {'nonempty'}, funcname, 'mapProj')

    % for now use validateattributes
    %throwAsCaller(MException('MATFUNCLIB:libraster:parseMapProjection', 'InvalidInput'));
    
   % if mapProj is a string or char, assume it is a wkt string
   if isa(mapProj, 'char') || isa(mapProj, 'string')
      if isgeo
         try
            mapProj = geocrs(mapProj);
         catch ME
            rethrow(ME);
         end
      else
         try
            mapProj = projcrs(mapProj);
         catch ME
            rethrow(ME);
         end
      end
   else
      % mapProj is already a projcrs or geocrs
   end

elseif nargin == 3

   projCode = varargin{1};
   projAuth = varargin{2};
   
   validateattributes(projCode, {'numeric'}, {'nonempty'}, ...
      funcname, 'projCode')
   validateattributes(projAuth, {'char', 'string'}, {'nonempty'}, ...
      funcname, 'projAuth')
   
   % Try to create the map projection
   if isgeo
      try
         mapProj = geocrs(projCode, "Authority", projAuth);
      catch ME
         rethrow(ME);
      end
   else
      try
         mapProj = projcrs(projCode, "Authority", projAuth);
      catch ME
         rethrow(ME);
      end
   end
end

% mapProj is a projcrs or geocrs, confirm it matches tfgeo
if isgeo
   assert(isa(mapProj, 'geocrs'), 'Inconsistent coordinate system')
else
   assert(isa(mapProj, 'projcrs'), 'Inconsistent coordinate system')
end

% Parse outputs
% [varargout{1:nargout}] = dealout(argout1, argout2)

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
% THIS SOFTWARE IS PROVIDED BMAPPROJ THE COPMAPPROJRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANMAPPROJ EMAPPROJPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITMAPPROJ AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPMAPPROJRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANMAPPROJ DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EMAPPROJEMPLARMAPPROJ, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANMAPPROJ THEORMAPPROJ OF LIABILITMAPPROJ, WHETHER IN CONTRACT, STRICT LIABILITMAPPROJ,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANMAPPROJ WAMAPPROJ OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITMAPPROJ OF SUCH DAMAGE.
