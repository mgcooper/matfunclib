function tests = test_dealout
   tests = functiontests(localfunctions);
end

function testSingleInput(testCase)
   [out] = dealout(10);
   testCase.verifyEqual(out, 10);
end

function testMultipleInputs(testCase)
   [a, b, c] = dealout(1, 2, 3);
   testCase.verifyEqual( a, 1);
   testCase.verifyEqual( b, 2);
   testCase.verifyEqual( c, 3);
end

function testStructInput(testCase)
   s.a = 1; s.b = 2;
   [a, b] = dealout(s);
   testCase.verifyEqual( a, 1);
   testCase.verifyEqual( b, 2);
end

function testCellInput(testCase)
   c = {1, 2, 3};
   [a, b, c] = dealout(c{:});
   testCase.verifyEqual( a, 1);
   testCase.verifyEqual( b, 2);
   testCase.verifyEqual( c, 3);
end

function testScalarCellInputExpansion(testCase)
   c = {1, 2, 3};
   [a, b, c] = dealout(c);
   testCase.verifyEqual( a, 1);
   testCase.verifyEqual( b, 2);
   testCase.verifyEqual( c, 3);
end

function testExcessNargout(testCase)
   % A wrapper function to request more outputs than inputs
   function wrapper()
      [a, b, c] = dealout(1);
   end
   % Test the wrapper function for the expected error
   % testCase.verifyError(@wrapper, 'MATLAB:badsubscript');
   % testCase.verifyError(@wrapper, 'custom:dealout:OutputsExceedInputs');
end

function testNoInputsProvidedAndNoOutputsRequested(testCase)
   % Test dealout with no inputs
   function wrapper()
      dealout();
   end
   testCase.assertTrue(true);
   testCase.verifyWarningFree(@wrapper);
end

function testNoInputsProvidedButOutputsRequested(testCase)
   % Test dealout with no inputs
   function wrapper()
      [a, b, c] = dealout();
   end
   % Test the wrapper function for the expected error
   % testCase.verifyError(@wrapper, 'custom:dealout:OutputsExceedInputs');
end

function testScalarCellWarning(testCase)
   c = {1};
   % testCase.verifyWarning(@()dealout(c), 'custom:dealout:ScalarCellInput');
end

function testNoOutputsRequested(testCase)
   % Test dealout with inputs but no outputs requested
   function wrapper()
      dealout(1, 2, 3);
   end
   assertTrue(testCase, true);
   testCase.verifyWarningFree(@wrapper);

   % % Could also use evalc to capture any output and ignore it
   % evalc('dealout(1, 2, 3);');
   % assertTrue(testCase, true);
end

function testMixedDataTypes(testCase)
   [a, b, c] = dealout(1, 'two', {3});
   testCase.verifyEqual(a, 1);
   testCase.verifyEqual(b, 'two');
   testCase.verifyTrue(isequal(c, {3}));
end

function testNestedCellArrays(testCase)
   nestedCell = {{1, 2}, {3, 4}};
   [a, b] = dealout(nestedCell{:});
   testCase.verifyTrue(isequal(a, {1, 2}));
   testCase.verifyTrue(isequal(b, {3, 4}));
end

function testLargeNumberOfInputs(testCase)
   inputs = num2cell(1:100); % Generate a large number of inputs
   [varargout{1:100}] = dealout(inputs{:});
   expected = num2cell(1:100);
   testCase.verifyEqual( varargout, expected);
end

function testComplexStructHandling(testCase)
   s.a = 1; s.b = {2, 3}; s.c = struct('d', 4);
   [a, b, c] = dealout(s);
   testCase.verifyEqual( a, 1);
   testCase.verifyTrue(isequal(b, {2, 3}));
   testCase.verifyTrue(isequal(c, struct('d', 4)));
end

function testCellArrays(testCase)
   arg1 = cell(10, 1);
   arg2 = cell(10, 1);
   arg3 = cell(10, 1);

   varargout = dealout2(arg1, arg2, arg3);

   % need to test dealout2 when the calling function requests
end
