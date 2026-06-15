classdef testLoadgis < matlab.unittest.TestCase
   %TESTLOADGIS End-to-end round-trip tests for loadgis.
   %
   % Confirms loadgis reads a shapefile without erroring on the (previously
   % missing) parser2varargin call, and that an explicitly set option is forwarded
   % to shaperead. Uses a Mapping Toolbox sample shapefile resolved to a full path,
   % so loadgis skips the USERGISPATH lookup and no staged user data is required.

   properties
      Shapefile  % full path to a sample shapefile, or '' if unavailable
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         % Put the whole project on the path so loadgis and its helpers resolve.
         import matlab.unittest.fixtures.PathFixture

         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end

      function resolveSampleShapefile(testCase)
         % Prefer a geographic sample; fall back to a planar one. which() returns
         % the full path when the Mapping Toolbox sample data is installed.
         candidates = {'landareas.shp', 'concord_roads.shp'};
         testCase.Shapefile = '';
         for c = candidates
            found = which(c{1});
            if ~isempty(found)
               testCase.Shapefile = found;
               break
            end
         end
      end
   end

   methods (Test)
      function testRoundTripWithDefaults(testCase)
         % loadgis on the full path must read the shapefile and return a non-empty
         % geostruct, exercising the restored parser2varargin path with no options.
         testCase.assumeFalse(isempty(testCase.Shapefile), ...
            "No Mapping Toolbox sample shapefile available; skipping.");

         returned = loadgis(testCase.Shapefile);

         testCase.verifyNotEmpty(returned);
         testCase.verifyTrue(isstruct(returned));
      end

      function testRoundTripForwardsUserSetOption(testCase)
         % An explicitly set option (UseGeoCoords) must flow through
         % parser2varargin to shaperead without error and still return data.
         testCase.assumeFalse(isempty(testCase.Shapefile), ...
            "No Mapping Toolbox sample shapefile available; skipping.");

         returned = loadgis(testCase.Shapefile, "UseGeoCoords", true);

         testCase.verifyNotEmpty(returned);
         testCase.verifyTrue(isstruct(returned));
      end
   end
end
