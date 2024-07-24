function tests = test_isfieldname
   tests = functiontests(localfunctions);
end

function testStructFieldFound(testCase)
   S = struct('Name', 1, 'age', 25);
   [tf, name] = isfieldname(S, 'name');
   testCase.verifyTrue(tf);
   testCase.verifyEqual(name{1}, 'Name');
end

function testTableFieldFound(testCase)
   T = table(1, 2, 'VariableNames', {'id', 'Name'});
   [tf, name] = isfieldname(T, 'name');
   testCase.verifyTrue(tf);
   testCase.verifyEqual(name{1}, 'Name');
end

function testTimetableFieldFound(testCase)
   TT = timetable(1, 2, 'VariableNames', {'Temperature', 'Humidity'}, ...
      'RowTimes', seconds(1));
   [tf, name] = isfieldname(TT, 'temperature');
   testCase.verifyTrue(tf);
   testCase.verifyEqual(name{1}, 'Temperature');
end

function testMultipleFieldsFound(testCase)
   S = struct('Name', 1, 'Age', 25);
   [tf, name] = isfieldname(S, {'Name', 'age', 'Gender'});
   testCase.verifyEqual(tf, [true true false]);
   testCase.verifyEqual(name{1}, 'Name');
   testCase.verifyEqual(name{2}, 'Age');
   testCase.verifyTrue(isempty(name{3}));
end

function testNoFieldsFound(testCase)
   S = struct('Name', 1, 'age', 25);
   [tf, name] = isfieldname(S, 'height');
   testCase.verifyFalse(tf);
   testCase.verifyTrue(isempty(name{1}));
end

function testInputTypeChar(testCase)
   S = struct('Name', 1, 'age', 25);
   [tf, name] = isfieldname(S, 'name');
   testCase.verifyTrue(tf);
   testCase.verifyEqual(name{1}, 'Name');
end

function testInputTypeString(testCase)
   S = struct('Name', 1, 'age', 25);
   [tf, name] = isfieldname(S, "age");
   testCase.verifyTrue(tf);
   testCase.verifyEqual(name{1}, 'age');
end

function testInputTypeCellStr(testCase)
   T = table(1, 2, 'VariableNames', {'id', 'Name'});
   [tf, name] = isfieldname(T, {'ID', 'name'});
   testCase.verifyEqual(tf, [true true]);
   testCase.verifyEqual(name{1}, 'id');
   testCase.verifyEqual(name{2}, 'Name');
end

% function testUnsupportedDataType(testCase)
%     % Verify error for unsupported data types
%     A = [1, 2, 3]; % Array, not a struct, table, or timetable
%     testCase.verifyError( @() isfieldname(A, 'name'), 'MATLAB:validators:mustBeA');
% end
