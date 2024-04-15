function tests = rasterTests
   %RASTERTESTS Test libraster.
   tests = functiontests(localfunctions);
end

function setup(testCase)
   % This setup function was designed for gridmember, it creates a coordinate
   % pair list with one missing coordinate-pair (6, 2).

   % Set x=3, y=1 missing.
   coords = [
      4, 2
      4, 3
      5, 2
      5, 3
      6, 3] ;

   % Notes on the expected results. The grid above in x,y format with y
   % increasing up and x increasing right:
   % 4,3 5,3 6,3
   % 4,2 5,2 <missing>
   %
   % If complete:
   % 4,3 5,3 6,3
   % 4,2 5,2 6,2
   %
   % Therefore the expected result for a full-grid representation is:
   % 2×3 logical array
   % 1   1   1
   % 1   1   0
   %
   % The expected result for a coordinate list:
   % 6×1 logical array
   % 1
   % 1
   % 1
   % 1
   % 1
   % 0
   %
   % The expected result for x-grid vector:
   % 1×3 logical array
   % 1   1   0
   %
   % The expected result for y-grid vector:
   % 2×1 logical array
   % 1
   % 0
   %
   % However, notice that the information in the two logical "grid vectors" is
   % not sufficient to recover the fact that only one coordinate pair is
   % missing. Therefore, although the function does return the "correct" answer
   % when GridOption=gridvectors, note that the values returned represent
   % rows/columns with NO missing values.

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
end

function teardown(testCase)
end

%% test gridmember
function test_gridmember_fullgrids(testCase)

   % Test X2/Y2 = fullgrids, X1/Y1 = coordinates
   returnedValue = gridmember( ...
      testCase.TestData.xgrid, testCase.TestData.ygrid, ...
      testCase.TestData.xcoords, testCase.TestData.ycoords);

   verifyEqual(testCase, returnedValue, testCase.TestData.expectedValue)
end

function test_gridmember_coordinates(testCase)

   % Test X2, Y2 = coordinates, X1, Y1 = coordinates
   returnedValue = gridmember( ...
      testCase.TestData.xgrid(:), testCase.TestData.ygrid(:), ...
      testCase.TestData.xcoords, testCase.TestData.ycoords);

   verifyEqual(testCase, returnedValue, testCase.TestData.expectedValue(:))
end

function test_gridmember_gridvecsX(testCase)

   % Test X2, Y2 = gridvecs, X1, Y1 = coordinates
   [returnedValueX, ~] = gridmember( ...
      testCase.TestData.xvec, testCase.TestData.yvec, ...
      testCase.TestData.xcoords, testCase.TestData.ycoords);

   verifyEqual(testCase, returnedValueX, testCase.TestData.expectedValueX)
end

function test_gridmember_gridvecsY(testCase)

   % Test X1, Y1 = coordinates, X2, Y2 = gridvecs
   [~, returnedValueY] = gridmember( ...
      testCase.TestData.xvec, testCase.TestData.yvec, ...
      testCase.TestData.xcoords, testCase.TestData.ycoords);

   verifyEqual(testCase, returnedValueY, testCase.TestData.expectedValueY)
end

function test_gridmember_gridvecsX_2(testCase)

   % Test X1, Y1 = coordinates, X2, Y2 = gridvecs
   [returnedValueX, ~] = gridmember( ...
      testCase.TestData.xgrid(:), testCase.TestData.ygrid(:), ...
      testCase.TestData.xcoords, testCase.TestData.ycoords, 'gridvectors');

   verifyEqual(testCase, returnedValueX, testCase.TestData.expectedValueX)
end

function test_gridmember_gridvecsY_2(testCase)

   % Test X1, Y1 = coordinates, X2, Y2 = gridvecs
   [~, returnedValueY] = gridmember( ...
      testCase.TestData.xgrid(:), testCase.TestData.ygrid(:), ...
      testCase.TestData.xcoords, testCase.TestData.ycoords, 'gridvectors');

   verifyEqual(testCase, returnedValueY, testCase.TestData.expectedValueY)
end

%% test prepareMapGrid
function test_prepareMapGrid(testCase)

   [X, Y, CellSizeX, CellSizeY, GridType, tfGeoCoords, I, LOC] = prepareMapGrid( ...
      testCase.TestData.xcoords, testCase.TestData.ycoords);

   verifyEqual(testCase, I, testCase.TestData.expectedValue)
end
