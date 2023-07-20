function varargout = fullgrid(varargin)
%FULLGRID convert vectors to fullgrid (meshgrid) format
%
%  X = FULLGRID(X) convert coordinate vector X to fullgrid (meshgrid) format
%  Y = FULLGRID(Y) convert coordinate vector Y to fullgrid (meshgrid) format
%  Y = FULLGRID([], Y) convert coordinate vector Y to fullgrid (meshgrid) format
%  sorted in decreasing order exactly like it would be in fullgrid format
%  [X, Y] = FULLGRID(X, Y) convert X, Y coordinates to fullgrid (meshgrid) format
%  [X, Y] = FULLGRID(X, Y, 'gridvectors') returns X, Y as grid vectors
%  [X, Y] = FULLGRID(X, Y, 'coordinates') returns X, Y as coordinate-pair lists
% 
% Example
%
%
%
% Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper
%
% See also gridvec, fastgrid, meshgrid, ndgrid

% Note: a lot of work went into getting this to output X or Y to enable syntax
% like [fullgrid(X, 'coordinates'), fullgrid(Y, 'coordinates')] e.g. see
% isfullgrid, but that ends up failing often when the individual "fullgrids" X
% and Y are not the same size.

%% main code

% input checks
narginchk(1, 3)

% Check for output format option
[opt, args, nargs] = parseoptarg(varargin, ...
   {'coordinates', 'gridvectors', 'fullgrids'}, 'fullgrids');

% Parse remaining arguments
X1 = args{1};
if nargs > 1
   Y1 = args{2};
else
   Y1 = X1;
end

% outarg = 1 means X, Y, outarg = 2 means Y, X. NOTE: this is experimental, in
% practice it turns out it might not be helpful b/c w/o X, the size of Y is not
% what it would be if X were supplied. Instead see xfullgrid, yfullgrid for
% vector output with nargout == 0 to chain in function calls.
outarg = 1;
if isempty(X1)
   outarg = 2;
   X1 = Y1;
end

% Convert X, Y to fullgrids oriented E-W (ascending) and N-S (descending)
[X2, Y2] = meshgrid(xgridvec(X1), ygridvec(Y1));
      
% Convert to requested output format
if strcmp(opt, 'coordinates')
   X2 = X2(:);
   Y2 = Y2(:);
elseif strcmp(opt,'gridvectors')
   [X2, Y2] = gridvec(X2, Y2);   
end

% Parse outputs
switch nargout
   case {0, 1}
      if outarg == 2
         varargout{1} = Y2;
      else
         varargout{1} = X2;
      end
   case 2
      varargout{1} = X2;
      varargout{2} = Y2;
end
      
end

%%
% X1 = args{1};
% if nargs > 1
%    Y1 = args{2};
% else
%    Y1 = X1;
% end
% 
% % Parse outputs
% switch nargs
% 
%    case 1
%       % Convert X to a fullgrid oriented E-W (ascending)
%       X2 = meshgrid(xgridvec(X1));
% 
%    case 2
%       % Convert X, Y to fullgrids oriented E-W (ascending) and N-S (descending)
%       [X2, Y2] = meshgrid(xgridvec(X1), ygridvec(Y1));
% end
% 
% switch opt{:}
%    case 'coordinates'
%       try
%          X2 = X2(:);
%          Y2 = Y2(:);
%       catch
%          X2 = X2(:);
%       end
%    case 'gridvectors'
%       try
%          [X2, Y2] = gridvec(X2, Y2);
%       catch
%          X2 = xgridvec(X2);
%       end
% end
% 
% [varargout{1:max(1,nargout)}] = dealout(X2, Y2);

%{ 
code graveyard

Started to parse the option the old school way then used parseoptarg

args = varargin;
nargs = nargin;
option = 'fullgrids';
if nargs > 2
   option = validatestring(varargin{3}, ...
      {'fullgrids', 'coordinates', 'gridvectors'}, mfilename, 'option', 3);
end

%}

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