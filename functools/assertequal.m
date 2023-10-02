function assertEqual(A, B, varargin)
   %ASSERTEQUAL Wrapper for assert(isequal(A, B), varargin)
   %
   %  ASSERTEQUAL(A, B) throws an error if A and B are not equal
   %
   %  ASSERTEQUAL(A, B, MSG) also displays the error message, MSG.
   %
   %  ASSERTEQUAL(A, B, EID, MSG) includes the error identifier EID in the
   %  displayed error message MSG.
   %
   %  ASSERTEQUAL(_, f1, ..., fN) displays an error message that contains
   %  formatting conversion characters such as those used in sprintf.
   %
   % See also: assertError assertSuccess assertWithRelTol assertWithAbsTol

   % PARSE INPUTS
   narginchk(0,Inf)
   [varargin{:}] = convertStringsToChars(varargin{:});

   % MAIN CODE
   assert(isequal(A, B), varargin{:});
end

%% TESTS
function test_assertequal()
   %TEST_ASSERTEQUAL test assertequal

   % Define test data
   [A, B] = deal([]);

   % Call sub-functions to perform different types of tests
   test_input_validation();
   test_function_accuracy(A, B);
   test_type_handling(A, B);
   test_dimension_handling(A, B); % passed A, B as parameter to keep it consistent.

end

function test_input_validation()

   % Test empty inputs
   try
      assertEqual();
      error('Expected an error for empty inputs, but none was thrown');
   catch ME
      assert(strcmp(ME.identifier, 'MATLAB:minrhs'));
   end

   % Test invalid inputs
   % Here 'invalid' is a string, replace it with a more suitable invalid input
   % for your function
   try
      assertEqual('invalid');
      error('Expected an error for invalid inputs, but none was thrown');
   catch ME
      assert(strcmp(ME.identifier, 'MATLAB:invalidInput'));
   end

   % Test too many input arguments
   % The number of arguments here should be more than the function can handle
   try
      assertEqual(1,2,3,4,5,6,7);
      error('Expected an error for too many inputs, but none was thrown');
   catch ME
      assert(strcmp(ME.identifier, 'MATLAB:TooManyInputs'));
   end

end

function test_function_accuracy(A, B)

   % Define the expected output
   expected = []; % add expected value
   tol = 20*eps;

   % Test function accuracy using assert
   observed = assertEqual(A, B);
   assert(isequal(observed, expected));

   % Test function accuracy using assert with tolerance
   assert(abs(observed - expected) < tol);

   % Test with edge cases (Inf, NaN, very large/small numbers)
   % The theoretical results here depend on your function's behavior
   assert(isnan(assertEqual(NaN)));
   assert(isinf(assertEqual(Inf)));
   assert(abs(assertEqual(1e200) - 1e200) < 1e-10);

   % more cases can be added

end

function test_type_handling(A, B)

   % Test different types, if the function is expected to handle them

   expected = []; % add expected value for double type
   assert(isequal(assertEqual(A, B), expected));

   expected = []; % add expected value for single type
   assert(isequal(assertEqual(single(A, B)), single(expected)));

   expected = []; % add expected value for logical type
   assert(isequal(assertEqual(logical(A, B)), expected));

   expected = []; % add expected value for int16 type
   assert(isequal(assertEqual(int16(A, B)), expected)); % int16

   % Add more as needed
end


function test_dimension_handling(A, B)

   % Test different dimensions
   % Replace with theoretical results here
   assert(isequal(assertEqual([2 3]), [4 6])); % 1D array
   assert(isequal(assertEqual([2 3; 4 5]), [4 6; 8 10])); % 2D array
   % Add more as needed

end

%!test

% ## add octave tests here

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