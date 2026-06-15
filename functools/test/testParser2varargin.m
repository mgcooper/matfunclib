classdef testParser2varargin < matlab.unittest.TestCase
   %TESTPARSER2VARARGIN Tests for parser2varargin.
   %
   % Guards the historical index bug: when a required argument precedes the
   % optional parameters (loadgis's case, where 'fname' is added first), the old
   % implementation forwarded the wrong name/value pairs.

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         % Put the whole project on the path so parser2varargin and struct2varargin
         % resolve without a manual addpath.
         import matlab.unittest.fixtures.PathFixture

         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Test)
      function testForwardsOnlyUserSetOptions(testCase)
         % Parse with a single optional parameter explicitly set; only that pair
         % must come back, with the required 'fname' and defaulted params excluded.
         parser = testCase.buildParser();
         parser.parse("file.shp", "UseGeoCoords", true);

         returned = parser2varargin(parser, {'fname'}, 'notusingdefaults');
         expected = {'UseGeoCoords', true};

         testCase.verifyEqual(returned, expected);
      end

      function testForwardsMultipleUserSetOptions(testCase)
         % Two user-set options come back as name/value pairs; defaults and the
         % required arg are still excluded. Inspect names/values directly rather
         % than via struct(), since a cell-valued option (Selector) would otherwise
         % be expanded into a struct array.
         parser = testCase.buildParser();
         selector = {@(x) true, 'NAME'};
         parser.parse("file.shp", "Selector", selector, "UseGeoCoords", true);

         returned = parser2varargin(parser, {'fname'}, 'notusingdefaults');
         names = returned(1:2:end);
         values = returned(2:2:end);

         testCase.verifyEqual(numel(returned), 4);
         testCase.verifyTrue(ismember('UseGeoCoords', names));
         testCase.verifyTrue(ismember('Selector', names));
         testCase.verifyFalse(ismember('fname', names));
         testCase.verifyFalse(ismember('reader', names));
         testCase.verifyTrue(values{strcmp(names, 'UseGeoCoords')});
         testCase.verifyEqual(values{strcmp(names, 'Selector')}, selector);
      end

      function testNoUserSetOptionsReturnsEmpty(testCase)
         % With nothing but the required arg supplied, there is nothing to forward.
         parser = testCase.buildParser();
         parser.parse("file.shp");

         returned = parser2varargin(parser, {'fname'}, 'notusingdefaults');

         testCase.verifyEmpty(returned);
      end

      function testUsingDefaultsReturnsTheDefaultedOptions(testCase)
         % The complementary mode returns the optional params left at their default.
         parser = testCase.buildParser();
         parser.parse("file.shp", "UseGeoCoords", true);

         returned = parser2varargin(parser, {'fname'}, 'usingdefaults');
         names = returned(1:2:end);

         testCase.verifyTrue(ismember('reader', names));
         testCase.verifyFalse(ismember('UseGeoCoords', names));
      end

      function testInvalidOptionErrors(testCase)
         parser = testCase.buildParser();
         parser.parse("file.shp");

         testCase.verifyError( ...
            @() parser2varargin(parser, {'fname'}, 'bogus'), ...
            'matfunclib:parser2varargin:badOption');
      end
   end

   methods (Access = private)
      function parser = buildParser(~)
         % Mirror loadgis's parseinputs: required 'fname' added first, then the
         % optional shaperead-facing parameters.
         parser = inputParser();
         parser.addRequired('fname', @(x) true);
         parser.addParameter('reader', 'shaperead', @(x) true);
         parser.addParameter('UseGeoCoords', false, @islogical);
         parser.addParameter('Selector', [], @iscell);
         parser.addParameter('Attributes', [], @iscell);
         parser.addParameter('BoundingBox', [], @isnumeric);
      end
   end
end
