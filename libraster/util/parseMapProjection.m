function mapProj = parseMapProjection(isgeo, varargin)
   %PARSEMAPPROJECTION Convert or verify map projection objects.
   %
   %  MAPPROJ = PARSEMAPPROJECTION(ISGEO, WKTSTRING) converts WKTSTRING to
   %  a geocrs object if ISGEO is true; otherwise, to a projcrs object.
   %
   %  MAPPROJ = PARSEMAPPROJECTION(ISGEO, PROJCODE, AUTHORITY) creates a geocrs
   %  object if ISGEO is true; otherwise, a projcrs object using the numeric
   %  scalar projection code PROJCODE and the provided authority, indicated by
   %  char or string AUTHORITY.
   %
   %  If the input is already a geo/projcrs object, it is returned as-is.
   %
   % See also: bbox2R

   % Input checks
   narginchk(2, 5)

   [varargin{:}] = convertStringsToChars(varargin{:});

   % Parse the optional 'forward' or 'inverse' argument
   [~, args, nargs] = parseoptarg(varargin, {'forward', 'inverse'}, 'forward');
   drop = cellfun(@(arg) ischar(arg) && strcmp(arg, 'Authority'), args);
   if any(drop)
      args = args(~drop);
      nargs = nargs - 1;
   end

   % Get the calling function name for error messages
   funcname = mcallername();
   if nargs+1 == 2
      mapProj = args{1};

      % Validate attributes of mapProj
      validateattributes(mapProj, {'projcrs', 'geocrs', 'char', 'string'}, ...
         {'nonempty'}, funcname, 'mapProj')

      % for now use validateattributes
      % throwAsCaller(MException( ...
      %    'MATFUNCLIB:libraster:parseMapProjection', 'InvalidInput'));

      % If mapProj is a string or char, assume it is a WKT string
      if ischar(mapProj) || isstring(mapProj)
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
      end

   elseif nargs+1 == 3

      projCode = args{1};
      projAuth = args{2};

      % Validate attributes
      validateattributes(projCode, {'numeric'}, {'nonempty', 'scalar'}, ...
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

   % This is too restrictive. Whether the coordinates are lat lon or planar,
   % most likely the projection should be a projcrs (map proj) object, which is
   % used for both forward and inverse transformations from/to planar or geo
   % % Confirm that mapProj is a projcrs or geocrs matching isgeo
   % if isgeo % && strcmp(opt, 'forward') % || ~isgeo && strcmp(opt, 'inverse')
   %    assert(isa(mapProj, 'geocrs'), 'Inconsistent coordinate system')
   % else
   %    assert(isa(mapProj, 'projcrs'), 'Inconsistent coordinate system')
   % end
end

%% LICENSE

% BSD 3-Clause License
%
% Copyright (c) 2023, Matt Cooper (mgcooper) All rights reserved.
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
%    contributors may be used to endorse or promote products derived from this
%    software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BMAPPROJ THE COPMAPPROJRIGHT HOLDERS AND
% CONTRIBUTORS "AS IS" AND ANMAPPROJ EMAPPROJPRESS OR IMPLIED WARRANTIES,
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITMAPPROJ
% AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
% COPMAPPROJRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANMAPPROJ DIRECT,
% INDIRECT, INCIDENTAL, SPECIAL, EMAPPROJEMPLARMAPPROJ, OR CONSEQUENTIAL DAMAGES
% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
% ANMAPPROJ THEORMAPPROJ OF LIABILITMAPPROJ, WHETHER IN CONTRACT, STRICT
% LIABILITMAPPROJ, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
% ANMAPPROJ WAMAPPROJ OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITMAPPROJ OF SUCH DAMAGE.
