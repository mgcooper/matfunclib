function [V, X, Y] = validateGridData(V, X, Y, funcname, argname1, argname2, argname3, gridOption)
   %VALIDATEGRIDDATA Validate gridded data for function inputs.
   %
   % See also xyzchk

   if nargin < 4 || isempty(funcname); funcname = mcallername(); end
   if nargin < 5 || isempty(argname1); argname1 = 'X'; end
   if nargin < 6 || isempty(argname2); argname2 = 'Y'; end
   if nargin < 7 || isempty(argname3); argname3 = 'V'; end
   if nargin < 8 || isempty(gridOption); gridOption = 'unspecified'; end


   validateGridCoordinates(X, Y, funcname, 'X', 'Y', gridOption);
   validateattributes(V, {'numeric', 'logical'}, {'3d'}, funcname, 'V');

   % If using R
   % validateattributes(V, {'numeric', 'logical'}, {'size', R.RasterSize}, ...
   %    funcname, 'V', 3)

   % Convert X and Y to columns and ensure the first two dimensions of V match X,Y
   X = X(:);
   Y = Y(:);
   switch ndims(V)
      case 3
         V = reshape(V, size(V, 1) * size(V, 2), []);
      case 2
         if numel(X) == numel(V)
            V = V(:);
         end % otherwise, size(V) must be [numel(X), numsamples]
   end

   % This will catch the case where size(V) is not [numel(X), numsamples]
   assert( numel(X) == size(V, 1), ...
      sprintf('matfunclib:%s:inconsistentXYV', funcname), ...
      ['Function %s expected the first two dimensions of input argument ' ...
      'V to match X and Y in size.'], upper(funcname))
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
