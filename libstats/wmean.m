function y = wmean(x, w, varargin)
   %WMEAN Weighted average or mean value.
   %
   %  Y = WMEAN(X, W)
   %  Y = WMEAN(X, W, DIM)
   %  Y = WMEAN(X, W, VECDIM)
   %  Y = WMEAN(X, W, 'ALL')
   %  Y = WMEAN(_, OUTTYPE)
   %  Y = WMEAN(_, NANFLAG)
   %
   %  Y = WMEAN(X,W) computes the weighted mean value of the elements in X using
   %  non-negative weights W. If X is a vector, Y is a vector. If X is a matrix,
   %  Y is a row vector containing the weighted mean value of each column. For
   %  N-D arrays, Y is the weighted mean value of the elements along the first
   %  non-singleton dimension of X. Each element of X requires a corresponding
   %  weight, and hence the size of W must match that of X.
   %
   %  Y = WMEAN(X, W, DIM) takes the weighted mean along the dimension DIM of X.
   %
   %  Example:
   %     x = rand(5,2);
   %     w = rand(5,2);
   %     wmean(x,w)
   %
   % See also:

   % Validate inputs
   narginchk(2, 5)
   assert(all(isequal(size(x), size(w))), ...
      'libstats:wmean:wrongSizeWeights', 'Expected one weight, W, for each X');
   assert(all(w(:) > 0), ...
      'libstats:wmean:allZeroWeights', 'Expected weights, W, to be non-negative')
   assert(~all(w(:) == 0), ...
      'libstats:wmean:noNonZeroWeights', 'Expected at least one non-zero weight, W')

   % Set weights to NaN where x is NaN
   if any(strcmpi(varargin, 'omitnan'))
      w(isnan(x)) = NaN;
      % w(isnan(x)) = 0;
   % else % or this? 
      % w(isnan(x)) = 0;
   end

   % Get the DIM (or VECDIM) if provided
   if any(strcmpi('all', varargin))
      dim = 'all';
      varargin = varargin(~strcmpi(varargin, 'all'));
   else

      if nargin > 2
         idim = cellfun(@isnumeric, varargin);
         assert(sum(idim) <= 1, 'Expected one numeric optional input');
         if any(idim)
            dim = varargin{idim};
         else
            dim = [];
         end
         varargin = varargin(~idim);
      else
         % If DIM was not provided, determine which dimension SUM will use.
         dim = find(size(x) ~= 1, 1, 'first');
      end

      % If the dim check turned up empty, set to 1.
      if isempty(dim)
         dim = 1;
      end
   end

   % Compute the weighted mean. Try the default inputs to sum, some of which may
   % fail on older matlab versions.
   try
      y = sum(w.*x, dim, varargin{:}) ./ sum(w, dim, varargin{:});
   catch
      y = sum(w.*x, dim) ./ sum(w, dim);
   end
end

%% TESTS

%!test

% ## add octave tests here

%% LICENSE
%
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
