function varargout = arraymap(fn, varargin)
   %ARRAYMAP apply a function to an array, returning a cell array of results.
   %
   %  A = ARRAYMAP(A)
   %
   % This function is equivalent to:
   % arraymap = @(fn, varargin) arrayfun(fn, varargin{:}, 'UniformOutput', false); 
   %
   % Example
   %
   % Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, github.com/mgcooper
   %
   % See also cellmap

   [varargout{1:nargout}] = arrayfun(fn, varargin{:}, 'UniformOutput', false);

   %    % In a prior commit I commented out the standard behavior above and changed
   %    % to this:
   %    out = arrayfun(fn, varargin{:}, 'UniformOutput', false);
   %    % If out is changed to [varargout{1:nargout}], then the stuff below does
   %    % catenate the individual outputs of arrayfun into one uniform array, when I
   %    % got here from bfra.eventfinder, I wanted T, Q, R, Info returned, but it
   %    % failed so when I did the thing above I must have been working with a
   %    % function that returned one argument, and I wanted a vector or matrix
   %    % instead of a cell array, but if I change to [varargout{1:nargout}] then it
   %    % will put T, Q< R, Info into one Nx4 cell array, which could be useful, so
   %    % maybe add an option to do that
   %
   %    % try to put in a uniform array
   %    try
   %       if isrow(out{1})
   %          [varargout{1:nargout}] = vertcat(out{:});
   %       elseif iscolumn(out{1})
   %          [varargout{1:nargout}] = horzcat(out{:});
   %       elseif ~isvector(out{1}) && ismatrix(out{1})
   %          % ambiguous, return to this later
   %       elseif numel(size(out{1})) == 3
   %          [varargout{1:nargout}] = cat(3, out{:});
   %       end
   %    catch
   %       [varargout{1:nargout}] = out;
   %    end

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
