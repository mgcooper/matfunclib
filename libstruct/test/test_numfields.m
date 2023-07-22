function tests = test_numfields()
   %TEST_NUMFIELDS test numfields
   tests = functiontests(localfunctions);
end

function setup(testCase)
   % Save the test data
   testCase.TestData.S = struct('field1', 'value1', 'field2', 'value2');
end

function teardown(testCase) %#ok<INUSD> 
end

function test_input_validation(testCase)

% Test invalid inputs
verifyError(testCase, @() numfields('char'), "MATLAB:validation:UnableToConvert");

% Ensure that the function raises an error when not given enough input arguments
verifyError(testCase, @() numfields(), "MATLAB:minrhs");

% Test too many input arguments
verifyError(testCase, @() numfields(1,2,3,4,5,6,7), "MATLAB:TooManyInputs");

end

function test_function_accuracy(testCase)

S = testCase.TestData.S;

% Test function accuracy using test struct
expected = 2;
returned = numfields(S);
verifyEqual(testCase, returned, expected);

% Test function accuracy using nested structs
S.S2 = S;
expected = 4;
returned = numfields(S, 'layered');
verifyEqual(testCase, returned, expected);

end



% %TEST_NUMFIELDS test numfields
% 
% % Define test data
% S = struct('field1', 'value1', 'field2', 'value2');
% 
% %% Test empty inputs
% try
%    numfields();
%    error('Expected an error for empty inputs, but none was thrown');
% catch ME
%    assert(strcmp(ME.identifier, 'MATLAB:minrhs'));
% end
% 
% %% Test invalid inputs
% try
%    numfields('char');
%    error('Expected an error for invalid inputs, but none was thrown');
% catch ME
%    assert(strcmp(ME.identifier, 'MATLAB:validation:UnableToConvert'));
% end
% 
% %% Test too many input arguments
% try
%    numfields(1,2,3,4,5,6,7);
%    error('Expected an error for too many inputs, but none was thrown');
% catch ME
%    assert(strcmp(ME.identifier, 'MATLAB:TooManyInputs'));
% end
% 
% 
% %% test_function_accuracy
% 
% % Test function accuracy using test struct
% expected = 2;
% observed = numfields(S);
% assert(isequal(observed, expected));
% 
% % Test function accuracy using nested structs
% S.S2 = S;
% expected = 4;
% observed = numfields(S, 'layered');
% assert(isequal(observed, expected));