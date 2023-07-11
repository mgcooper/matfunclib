function V = naninterp1(X,V,method,extrap)
%NANINTERP1 1-d interpolation over NaN values in vector V
%
%   Vq = INTERP1(X,V) interpolates to find Vq, the values of the
%   underlying function V=F(X) at the query points Xq. 
% 
% Matt Cooper, 29 Dec 2022, https://github.com/mgcooper
% 
% See also: interp1

narginchk(1, 4)

% TODO: change input to varargin and if nargin==1, V=varargin{1} and so on.
if nargin == 1
   % NANINTERP1(V)
   V = X;
   X = 1:numel(V);
   method = 'linear';
   extrap = NaN;

elseif nargin == 2 || isempty(method)
   % NANINTERP1(X,V)
   method = 'linear';
   extrap = NaN;
elseif nargin == 3 || isempty(extrap)
   % NANINTERP1(X,V,method)
   extrap = NaN;
elseif nargin == 4
   if strcmp(extrap, 'extrap')
      % NANINTERP1(X,V,method,'extrap')
      validatestring(method, {'pchip', 'spline', 'makima'}, mfilename, 'method', 3);
   else
      % NANINTERP1(X,V,method,extrapval)
      validateattributes(extrap, {'numeric'}, {'scalar'}, mfilename, 'extrapval', 4);
   end
end

V(isnan(V)) = interp1(X(~isnan(V)), V(~isnan(V)), X(isnan(V)), method, extrap);




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