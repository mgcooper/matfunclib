classdef testGetplotdata < matlab.unittest.TestCase
   %TESTGETPLOTDATA Unit tests for getplotdata.
   %
   % getplotdata reads XData, YData, and ZData only from the axes children
   % that have each property. It skips a Text annotation, which has none
   % of them, and an image, which has no ZData.

   properties (TestParameter)
      % Each case holds a function that adds a second child to axes that
      % hold one line, and the expected XData, YData, and ZData. Children
      % are newest first, so the image data come before the line data.
      childcase = struct( ...
         'text', {{@(ax) text(ax, 1, 1, 'label'), ...
         1:3, 4:6, zeros(1, 0)}}, ...
         'image', {{@(ax) image(ax, magic(3)), ...
         {[1, 3]; 1:3}, {[1, 3]; 4:6}, zeros(1, 0)}})
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so getplotdata resolves from the repo
         % root without a manual addpath.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Test)
      function testSkipsChildrenWithoutProperty(testCase, childcase)
         % getplotdata returns the data of the children that have each
         % property and raises no error for the child that lacks one.
         [addchild, x_expected, y_expected, z_expected] = childcase{:};

         % Draw in a hidden figure that teardown closes.
         fig = figure('Visible', 'off');
         testCase.addTeardown(@close, fig)
         ax = axes(fig);
         plot(ax, 1:3, 4:6)
         hold(ax, 'on')
         addchild(ax);

         [x_returned, y_returned, z_returned] = getplotdata(ax);
         testCase.verifyEqual(x_returned, x_expected)
         testCase.verifyEqual(y_returned, y_expected)
         testCase.verifyEqual(z_returned, z_expected)
      end
   end
end
