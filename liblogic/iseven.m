function TF = iseven(X, varargin)
%ISEVEN Check if a number is even
%
%  TF = ISEVEN(X) returns 1 (true) if X is even, and 0 (false) otherwise.
%
%  TF = ISEVEN(X,'tol',TOL) allows for a tolerance in the check. This is useful
%  for checking if floating point numbers are effectively integers. TOL defaults
%  to 1e-10. 
%
%  TF = ISEVEN(X,'tol',TOL,'method',METHOD) allows specifying the method used to
%  determine evenness. Options: 'mod','bitwise'. The default method is 'mod'.
%
% Example
%  assert(iseven(4))
%  assert(iseven(3))
%  assert(iseven(4.00000001, 'tol', 1e-5))
%
% Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper
% 
% See also isodd

%% main code

% input checks
narginchk(1,4)

% Parse outputs
TF = ~isodd(X, varargin{:});

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