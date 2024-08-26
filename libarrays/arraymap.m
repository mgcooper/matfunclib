function varargout = arraymap(fn, varargin)
   %ARRAYMAP apply a function to an array, returning a cell array of results.
   %
   %  [out1, out2, ..., outN] = arraymap(fn, varargin{:})
   %
   % This function is equivalent to:
   %    arraymap = @(fn, varargin) arrayfun(fn, varargin{:}, 'UniformOutput', false);
   %
   % Example
   %
   % Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, github.com/mgcooper
   %
   % See also cellmap

   [varargout{1:nargout}] = arrayfun(fn, varargin{:}, 'UniformOutput', false);

   % This will concatenate uniform sized outputs into one array, but it assumes
   % rows and columns should be concatenated into 2d arrays, and 2d or higher
   % dimensional arrays should be concatenated along the next higher dim, which
   % may not be desired in general, so I've commented it out. Instead, use
   % cellflatten with the appropriate dim argument.
   % sizes = cellfun(@size, varargout, 'UniformOutput', false);
   %
   % if all(cellfun(@(sz) isequal(sz, sizes{1}), sizes)) && nargout == 1
   %
   %    if isscalar(varargout{1})
   %       varargout = vertcat(varargout{:});
   %
   %    elseif isrow(varargout{1})
   %       varargout = vertcat(varargout{:});
   %
   %    elseif iscolumn(varargout{1})
   %       varargout = horzcat(varargout{:});
   %
   %    elseif ~isvector(varargout{1})
   %       varargout = cat(ndims(varargout{1})+1, varargout{:});
   %    end
   % end
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
% THIS SOFTWARE IS PROVIDED BA THE COPARIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANA EAPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITA AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPARIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANA DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EAEMPLARA, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANA THEORA OF LIABILITA, WHETHER IN CONTRACT, STRICT LIABILITA,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANA WAA OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITA OF SUCH DAMAGE.
