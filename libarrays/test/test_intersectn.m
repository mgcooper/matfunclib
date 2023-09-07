%TEST_INTERSECTN Test for the function intersectn
%#ok<*NASGU> 

% Define test data
A1 = [1, 20, 10];
A2 = [19, 2, 20];
A3 = [1, 21, 20, 1];

%% Test0: Confirm success with basic inputs

% Test without window size and with ComparisonMethod "all" and "any"
eid = 'matfunclib:libarrays:intersectn';
msg = 'Test method "all", window size = 0';
assertSuccess(@() ...
   intersectn(A1, A2, A3, 'ComparisonMethod', "all", 'WindowSize', 0), eid, msg);

msg = 'Test method "any", window size = 0';
assertSuccess(@() ...
   intersectn(A1, A2, A3, 'ComparisonMethod', "any", 'WindowSize', 0), eid, msg);

% Test with window size 1
msg = 'Test method "all", window size = 1';
assertSuccess(@() ...
   intersectn(A1, A2, A3, 'ComparisonMethod', "all", 'WindowSize', 0), eid, msg);

msg = 'Test method "any", window size = 1';
assertSuccess(@() ...
   intersectn(A1, A2, A3, 'ComparisonMethod', "any", 'WindowSize', 0), eid, msg);


%% Test1: ComparisonMethod = "all" and WindowSize = 0
expected = 20;
I = intersectn(A1, A2, A3, ComparisonMethod="all", WindowSize=0);
assert(isequal(I, expected), 'Test 1 failed');

%% Test2: ComparisonMethod = "any" and WindowSize = 0
expected = [1, 20];
[I, Lia, Locb] = intersectn(A1, A2, A3, ComparisonMethod="any", WindowSize=0);
assert(isequal(I, expected), 'Test 2 failed to find intersection');

expected = {[1 1 0], [0 0 1],[1 0 1 1]};
assert(isequal(Lia, expected), 'Test 2 failed to find Lia indices');

expected = {[1 2 0], [0 0 2], [1 0 2 1]};
assert(isequal(Locb, expected), 'Test 2 failed to find Locb indices');

%% Test3: No elements are common to all arrays, WindowSize = 0

% Remove the 20 so no elements are common to all arrays. 
A1 = [1, 20, 10];
A2 = [19, 2];
A3 = [1, 21, 20, 1];

expected = double.empty(1,0);
I = intersectn(A1, A2, A3, ComparisonMethod="all", WindowSize=0);
assert(isequal(I, expected), 'Test 3 failed with method "all"');

% 1 and 20 are still common to at least one other. 
expected = [1, 20];
[I, Lia, Locb] = intersectn(A1, A2, A3, ComparisonMethod="any", WindowSize=0);
assert(isequal(I, expected), 'Test 3 failed with method "any"');

expected = {[1 1 0], [0 0],[1 0 1 1]};
assert(isequal(Lia, expected), 'Test 3 failed to find Lia indices');

expected = {[1 2 0], [0 0], [1 0 2 1]};
assert(isequal(Locb, expected), 'Test 3 failed to find Locb indices');

%% Test4: Elements in common with WindowSize = 1

A1 = [1, 20, 10];
A2 = [19, 2];
A3 = [1, 21, 20, 1];

expected = [1, 2, 19, 20];
I = intersectn(A1, A2, A3, ComparisonMethod="all", WindowSize=1);
assert(isequal(I, expected), 'Test 4 failed with method "all"');

% With method "any", 21 should also be included
expected = [1, 2, 19, 20, 21];
[I, Lia, Locb] = intersectn(A1, A2, A3, ComparisonMethod="any", WindowSize=1);
assert(isequal(I, expected), 'Test 4 failed with method "any"');

expected = {[1 1 0], [1 1],[1 1 1 1]};
assert(isequal(Lia, expected), 'Test 4 failed to find Lia indices');

expected = {[1 4 0], [3 2], [1 5 4 1]};
assert(isequal(Locb, expected), 'Test 4 failed to find Locb indices');

%% Test5: Common to one array but not the third one, WindowSize = 1

% Test "any" with an element (10) that is common to one (11 in A2) but not the
% third array, and an element common to one other in its own array (30 and 31 in
% A1) but no other arrays. 
A1 = [1, 20, 10, 30, 31];
A2 = [19, 2, 11];
A3 = [1, 21, 20, 1];

expected = [1, 2, 19, 20];
I = intersectn(A1, A2, A3, ComparisonMethod="all", WindowSize=1);
assert(isequal(I, expected), 'Test 5 failed with method "all"');

% 10 and 11 and 21 should be included with method "any"
expected = [1, 2, 10, 11, 19, 20, 21];
I = intersectn(A1, A2, A3, ComparisonMethod="any", WindowSize=1);
assert(isequal(I, expected), 'Test 5 failed with method "any"');

% 30 and 31 should be included if window size = 10
expected = [1, 2, 10, 11, 19, 20, 21, 30, 31];
I = intersectn(A1, A2, A3, 'ComparisonMethod', "any", 'WindowSize', 10);
assert(isequal(I, expected), 'Test 5 failed with "WindowSize" 10');

%% Test6: Element common to only one other array, WindowSize = 0

% Test "any" for the case where an element is common to only one other array
A1 = [1, 30];
A2 = [1, 11];
A3 = [21];

expected = 1;
[I, Lia, Locb] = intersectn(A1, A2, A3, ComparisonMethod="any", WindowSize=0);
assert(isequal(I, expected), 'Test 6 failed with method "any"');

expected = {[1 0], [1 0],[0]};
assert(isequal(Lia, expected), 'Test 6 failed to find Lia indices');

expected = {[1 0], [1 0], [0]};
assert(isequal(Locb, expected), 'Test 6 failed to find Locb indices');

%% Test7: Element common to only one other array, WindowSize not zero

A1 = [1, 30];
A2 = [2, 11];
A3 = [21];

expected = 1:0;
I = intersectn(A1, A2, A3, ComparisonMethod="any", WindowSize=0);
assert(isequal(I, expected), 'Test 7 failed with method "all"');

expected = [1, 2];
I = intersectn(A1, A2, A3, ComparisonMethod="any", WindowSize=1);
assert(isequal(I, expected), 'Test 7 failed with method "any"');

%% Test8: Invalid inputs
assertError(@() ...
   intersectn({'invalid'}), 'intersectn:UnsupportedDataType', ...
   'Test 8 failed with input type cellstr');

assertError(@() ...
   intersectn("invalid"), 'intersectn:UnsupportedDataType', ...
   'Test 8 failed with input type string');

%% Test9: Custom assert functions for success
intersectn();
assertSuccess(@() intersectn(), '', ...
   'Test 9 failed on empty inputs, expected to succeed');

%% Test10: Error handling with edge cases (Inf, NaN, very large/small numbers)
A1 = [1, 20, 10];
A2 = [19, 2, 20];
A3 = Inf;
expected = double.empty(1,0);
I = intersectn(Inf, A1, A2, A3, ComparisonMethod="all");
assert(isequal(I, expected), 'Test 10 failed on Inf input with method "all"');

% 
expected = 20;
I = intersectn(Inf, A1, A2, A3, ComparisonMethod="any");
assert(isequal(I, expected), 'Test 10 failed on Inf input with method "any"');

% if window is Inf, all values should be found
expected = unique([A1, A2, A3]);
I = intersectn(Inf, A1, A2, A3, ComparisonMethod="any", WindowSize=Inf);
assert(isequal(I, expected), 'Test 10 failed on Inf input with method "any"');

% %% Test10: Dimension handling
% 
% This is not currently supported, but it should be - if all inputs are rows,
% the intersect should be a row etc. 
% 
% I = intersectn(A1', A2', A3', 'ComparisonMethod', "any", 'WindowSize', 10);
% assert(isequal(I, expected), 'Test 5 failed with "WindowSize" 10');
% 
% 
% %% Test type handling
% assert(isequal(intersectn(winSize, single(A1), single(A2), single(A3)), single(expected)));
% 
