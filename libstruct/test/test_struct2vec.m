function tests = test_struct2vec
   tests = functiontests(localfunctions);
end

function testAdaptiveShape(testCase)
   S.a = [1, 2, 3];
   S.b = [4, 5];
   actual = struct2vec(S, {'a', 'b'});
   expected = [1, 2, 3, 4, 5];
   testCase.verifyEqual(actual, expected);
end

function testMixedShapes(testCase)
   S.a = [1, 2, 3];
   S.b = [4; 5];
   S.c = [6, 7; 8, 9];
   actual = struct2vec(S, {'a', 'c', 'b'});
   expected = [1; 2; 3; 6; 8; 7; 9; 4; 5];
   testCase.verifyEqual(actual, expected);
end

function testRow(testCase)
   S.a = [1; 2; 3];
   S.b = [4; 5];
   S.c = [6; 7; 8; 9];
   actual = struct2vec(S, {'a', 'c', 'b'}, 'row');
   expected = [1 2 3 6 7 8 9 4 5];
   testCase.verifyEqual(actual, expected);
end

function testColumn(testCase)
   S.a = [1; 2; 3];
   S.b = [4; 5];
   S.c = [6; 7; 8; 9];
   actual = struct2vec(S, {'a', 'c', 'b'}, 'column');
   expected = [1; 2; 3; 6; 7; 8; 9; 4; 5];
   testCase.verifyEqual(actual, expected);
end
