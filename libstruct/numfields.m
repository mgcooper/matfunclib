function varargout = numfields(S, depth)
%NUMFIELDS count the number of fields in a struct
%
%  N = NUMFIELDS(S) returns the number of fields in struct S
%  S = NUMFIELDS(S,'layered') counts all fields in sub-structs
%
% Example
%
% S = struct('field1', 'value1', 'field2', 'value2'); % 
% numfields(S)
% 
% S.S2 = S;
% numfields(S)
% numfields(S, 'layered')
% 
% Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper
%
% See also


% PARSE ARGUMENTS
arguments
   S (:,1) struct
   depth (1,1) string {mustBeMember(depth,{'layered','flat'})} = 'flat'
end

% MAIN CODE
if strcmp(depth, 'flat')
   N = numel(fieldnames(S));
elseif strcmp(depth, 'layered')
   N = numel(fieldnames(flattenstruct(S)));
end

% PARSE OUTPUTS
[varargout{1:max(1,nargout)}] = dealout(N);

end


%% TESTS

%!test

%! ## Test empty inputs
%! try
%!    numfields();
%!    error('Expected an error for empty inputs, but none was thrown');
%! catch ME
%!    assert(strcmp(ME.identifier, 'MATLAB:minrhs'));
%! end
%! 
%! ## Test invalid inputs
%! try
%!    numfields('char');
%!    error('Expected an error for invalid inputs, but none was thrown');
%! catch ME
%!    assert(strcmp(ME.identifier, 'MATLAB:validation:UnableToConvert'));
%! end
%! 
%! ## Test too many input arguments
%! try
%!    numfields(1,2,3,4,5,6,7);
%!    error('Expected an error for too many inputs, but none was thrown');
%! catch ME
%!    assert(strcmp(ME.identifier, 'MATLAB:TooManyInputs'));
%! end
%! 

%! test function accuracy
%! 
%! ## Define test data
%! S = struct('field1', 'value1', 'field2', 'value2');
%! 
%! ## Test function accuracy using test struct
%! expected = 2;
%! observed = numfields(S);
%! assert(isequal(observed, expected));
%! 
%! ## Test function accuracy using nested structs
%! S.S2 = S;
%! expected = 4;
%! observed = numfields(S, 'layered');
%! assert(isequal(observed, expected));

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