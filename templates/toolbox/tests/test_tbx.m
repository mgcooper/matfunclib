function tests = test_tbx

try
   test_functions = localfunctions(); %#ok<*NASGU>
catch
   initTestSuite;
end

tests = functiontests(localfunctions);

% Note: setup and teardown are "fresh fixture functions" that run before and
% after each local test function. They are preferred over "file fixture
% functions" that run once per test file. They are not required, but are used to
% perform before and after actions. The only input is testCase.

function setup(testCase)
% Set x=3, y=1 missing.
coords = [
   4, 2
   4, 3
   5, 2
   5, 3
   6, 3] ;

% Create coordinate pairs, gridvecs, and fullgrids
xcoords = coords(:, 1);
ycoords = coords(:, 2);
[xvec, yvec] = gridvec(xcoords, ycoords);
[xgrid, ygrid] = fullgrid(xvec, yvec);

% Save the data
testCase.TestData.xcoords = xcoords;
testCase.TestData.ycoords = ycoords;
testCase.TestData.xvec = xvec;
testCase.TestData.yvec = yvec;
testCase.TestData.xgrid = xgrid;
testCase.TestData.ygrid = ygrid;
testCase.TestData.expectedValue = ~[false false false; false false true];
testCase.TestData.expectedValueX = ~[false false true];
testCase.TestData.expectedValueY = ~[false; true];

function teardown(testCase)

%% test gridmember
function test_gridmember_fullgrids(testCase)

% Test X2/Y2 = fullgrids, X1/Y1 = coordinates
returnedValue = gridmember( ...
   testCase.TestData.xgrid, testCase.TestData.ygrid, ...
   testCase.TestData.xcoords, testCase.TestData.ycoords);

verifyEqual(testCase, returnedValue, testCase.TestData.expectedValue)

function test_gridmember_coordinates(testCase)

% Test X2, Y2 = coordinates, X1, Y1 = coordinates
returnedValue = gridmember( ...
   testCase.TestData.xgrid(:), testCase.TestData.ygrid(:), ...
   testCase.TestData.xcoords, testCase.TestData.ycoords);

verifyEqual(testCase, returnedValue, testCase.TestData.expectedValue(:))

function test_gridmember_gridvecsX(testCase)

% Test X2, Y2 = gridvecs, X1, Y1 = coordinates
[returnedValueX, ~] = gridmember( ...
   testCase.TestData.xvec, testCase.TestData.yvec, ...
   testCase.TestData.xcoords, testCase.TestData.ycoords);

verifyEqual(testCase, returnedValueX, testCase.TestData.expectedValueX)

function test_gridmember_gridvecsY(testCase)

% Test X1, Y1 = coordinates, X2, Y2 = gridvecs
[~, returnedValueY] = gridmember( ...
   testCase.TestData.xvec, testCase.TestData.yvec, ...
   testCase.TestData.xcoords, testCase.TestData.ycoords);

verifyEqual(testCase, returnedValueY, testCase.TestData.expectedValueY)


function test_gridmember_gridvecsX_2(testCase)

% Test X1, Y1 = coordinates, X2, Y2 = gridvecs
[returnedValueX, ~] = gridmember( ...
   testCase.TestData.xgrid(:), testCase.TestData.ygrid(:), ...
   testCase.TestData.xcoords, testCase.TestData.ycoords, 'gridvectors');

verifyEqual(testCase, returnedValueX, testCase.TestData.expectedValueX)

function test_gridmember_gridvecsY_2(testCase)

% Test X1, Y1 = coordinates, X2, Y2 = gridvecs
[~, returnedValueY] = gridmember( ...
   testCase.TestData.xgrid(:), testCase.TestData.ygrid(:), ...
   testCase.TestData.xcoords, testCase.TestData.ycoords, 'gridvectors');

verifyEqual(testCase, returnedValueY, testCase.TestData.expectedValueY)

%% test prepareMapGrid

function test_prepareMapGrid(testCase)

[X, Y, CellSizeX, CellSizeY, GridType, tfGeoCoords, I, LOC] = prepareMapGrid( ...
   testCase.TestData.xcoords, testCase.TestData.ycoords);

verifyEqual(testCase, I, testCase.TestData.expectedValue)

