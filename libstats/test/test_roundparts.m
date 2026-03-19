function tests = test_roundparts()
   % Main function to collect all tests
   tests = functiontests(localfunctions);
end

function testSimpleCase(testCase)
   % Test 1: Simple case without binning
   parts = [30.2; 20.8; 49.0];
   returned = roundparts(parts);
   expected = [30; 21; 49];  % Expected result
   testCase.verifyEqual(sum(returned), 100, 'Sum should be 100');
   testCase.verifyEqual(returned, expected);
end

function testBinningCase(testCase)
   % Test 2: Binning case
   parts = [10.1; 20.2; 30.3; 39.4];
   binedges = [0, 30, 40];
   returned = roundparts(parts, 'Hamilton', 'binedges', binedges);
   expected = [10; 20; 30; 40];  % Expected result
   testCase.verifyEqual(sum(returned), 100, 'Sum should be 100');
   testCase.verifyEqual(returned, expected);
end

function testEqualPartsCase(testCase)
   % Test 3: Edge case with all equal parts
   parts = [33.3; 33.3; 33.4];
   returned = roundparts(parts);
   expected = [33; 33; 34];  % Expected result
   testCase.verifyEqual(sum(returned), 100, 'Sum should be 100');
   testCase.verifyEqual(returned, expected);
end

function testAlreadyRoundedCase(testCase)
   % Test 4: Already rounded parts
   parts = [25; 25; 25; 25];
   returned = roundparts(parts);
   expected = [25; 25; 25; 25];  % Expected result
   testCase.verifyEqual(sum(returned), 100, 'Sum should be 100');
   testCase.verifyEqual(returned, expected);
end

function testJeffersonMethod(testCase)
   % Test 5: Jefferson (D'Hondt) Method
   parts = [30.2; 20.8; 49.0];
   returned = roundparts(parts, 'Jefferson');
   expected = [30; 21; 49];  % Expected result using D'Hondt method
   testCase.verifyEqual(sum(returned), 100, 'Sum should be 100');
   testCase.verifyEqual(returned, expected);
end

function testWebsterMethod(testCase)
   % Test 6: Webster (Sainte-Laguë) Method
   parts = [30.2; 20.8; 49.0];
   returned = roundparts(parts, 'Webster');
   expected = [30; 21; 49];  % Expected result using Sainte-Laguë method
   testCase.verifyEqual(sum(returned), 100, 'Sum should be 100');
   testCase.verifyEqual(returned, expected);
end

function testAdamsMethod(testCase)
   % Test 7: Adams Method
   parts = [30.2; 20.8; 49.0];
   returned = roundparts(parts, 'Adams');
   expected = [31; 21; 48];  % Expected result using Adams method
   testCase.verifyEqual(sum(returned), 100, 'Sum should be 100');
   testCase.verifyEqual(returned, expected);
end

function testNonColumnInput(testCase)
   % Test 8: Ensure parts are treated as a column vector
   parts = [30.2, 20.8, 49.0];  % Row vector input
   returned = roundparts(parts);
   expected = [30; 21; 49];  % Expected result as column vector
   testCase.verifyEqual(size(returned, 2), 1, 'Output should be a column vector');
   testCase.verifyEqual(sum(returned), 100, 'Sum should be 100');
   testCase.verifyEqual(returned, expected);
end

function testEmptyParts(testCase)
   % Test 9: Handle empty input
   parts = [];
   testCase.verifyError(@() roundparts(parts), "MATLAB:validators:mustBeNonempty")
end

function testInvalidMethod(testCase)
   % Test 10: Handle invalid method input
   parts = [30.2; 20.8; 49.0];
   testCase.verifyError(@() roundparts(parts, 'InvalidMethod'), ...
      'MATLAB:validators:mustBeMember', 'Should throw an error for invalid method');
end
