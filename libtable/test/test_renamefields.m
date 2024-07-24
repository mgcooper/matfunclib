function tests = test_renamefields
   tests = functiontests(localfunctions);
end

function testRenameStructFields(testCase)
   s = struct('a', 1, 'b', 2, 'c', 3);
   [newStruct, found] = renamefields(s, ["a", "b"], ["alpha", "beta"]);
   expectedStruct = struct('alpha', 1, 'beta', 2, 'c', 3);

   % Thought this was needed but the tests were failing b/c of string vs cell
   % array equality test.
   % import matlab.unittest.constraints.IsEqualTo
   % import matlab.unittest.constraints.StructComparator
   % testCase.verifyThat(newStruct, IsEqualTo(expectedStruct, ...
   %    "Using", StructComparator))

   testCase.verifyEqual(newStruct, expectedStruct);
   testCase.verifyEqual(string(found), ["a", "b"]);
end

function testRenameStructFieldsEmptyOldFieldsError(testCase)
   s = struct('a', 1, 'b', 2, 'c', 3);
   verifyError(testCase, @() renamefields(s, [], "X"), ...
      'custom:renamefields:mustBeOneNewNamePerOldName');
end

function testRenameTableFieldsEmptyOldFieldsError(testCase)
   T = table([1; 2; 3], [4; 5; 6], 'VariableNames', {'A', 'B'});
   verifyError(testCase, @() renamefields(T, [], "X"), ...
      'custom:renamefields:mustBeOneNewNamePerOldName');
end

function testRenameStructFieldsEmptyOldFieldsSuccess(testCase)
   s = struct('a', 1, 'b', 2, 'c', 3);
   [newStruct, found] = renamefields(s, [], ["alpha", "beta", "gamma"]);
   expectedStruct = struct('alpha', 1, 'beta', 2, 'gamma', 3);

   testCase.verifyEqual(newStruct, expectedStruct);
   testCase.verifyEqual(string(found), ["a", "b", "c"]);
end

function testRenameTableFieldsEmptyOldFieldsSuccess(testCase)
   T = table([1; 2; 3], [4; 5; 6], 'VariableNames', {'A', 'B'});
   [newTable, found] = renamefields(T, [], ["alpha", "beta"]);
   expectedTable = table([1; 2; 3], [4; 5; 6], 'VariableNames', {'alpha', 'beta'});

   testCase.verifyEqual(newTable, expectedTable);
   testCase.verifyEqual(string(found), ["A", "B"]);
end

function testRenameTableVariables(testCase)
   T = table([1; 2; 3], [4; 5; 6], 'VariableNames', {'A', 'B'});
   [newTable, found] = renamefields(T, ["A", "B"], ["X", "Y"]);
   expectedTable = table([1; 2; 3], [4; 5; 6], 'VariableNames', {'X', 'Y'});
   verifyEqual(testCase, newTable, expectedTable);
   verifyEqual(testCase, string(found), ["A", "B"]);
end

function testMismatchedNamesLength(testCase)
   T = table([1; 2; 3], [4; 5; 6], 'VariableNames', {'A', 'B'});
   verifyError(testCase, @() renamefields(T, ["A", "B"], "X"), ...
      'custom:renamefields:mustBeOneNewNamePerOldName');
end

function testNonStructOrTableInput(testCase)
   T = [1; 2; 3];
   verifyError(testCase, @() renamefields(T, ["A", "B"], ["X", "Y"]), ...
      'custom:renamefields:inputMustBeStructOrTable');
end

function testNonexistentFields(testCase)
   s = struct('a', 1, 'b', 2);
   [newStruct, found] = renamefields(s, ["a", "c"], ["alpha", "gamma"]);
   expectedStruct = struct('alpha', 1, 'b', 2);
   verifyEqual(testCase, newStruct, expectedStruct);
   verifyEqual(testCase, string(found), "a");  % Only 'a' was found and renamed
end
