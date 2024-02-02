function X = xfullgrid(varargin)
   %XFULLGRID Convert vectors to fullgrid (meshgrid) format.
   %
   %  X = XFULLGRID(X) convert coordinate vector X to fullgrid (meshgrid) format
   %  X = XFULLGRID(X, Y) convert X, Y coordinates to fullgrid (meshgrid) format
   %  and return X.
   %  [X, Y] = XFULLGRID(X, Y, 'gridvectors') returns X as a grid vector
   %  [X, Y] = XFULLGRID(X, Y, 'coordinates') returns X as a coordinate list
   %
   % See also: gridvec, fastgrid, meshgrid, ndgrid

   % input checks
   narginchk(1, 3)

   % Check for output format option
   [opt, args, nargs] = parseoptarg(varargin, ...
      {'coordinates', 'gridvectors'}, 'fullgrid');

   % Parse remaining arguments
   X = args{1};
   if nargs > 1
      Y = args{2};
   else
      Y = X;
   end

   % Convert X, Y to fullgrids oriented E-W (ascending) and N-S (descending)
   X = meshgrid(xgridvec(X), ygridvec(Y));

   % Convert to requested output format
   if strcmp(opt, 'coordinates')
      X = X(:);
   elseif strcmp(opt,'gridvectors')
      X = xgridvec(X);
   else
      % fullgrid - default option
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
