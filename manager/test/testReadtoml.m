classdef testReadtoml < matlab.unittest.TestCase
   %TESTREADTOML Unit tests for the mproject.toml subset TOML parser.

   properties
      tomlDir string
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so readtoml resolves from the repo
         % root.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (TestMethodSetup)
      function makeTomlDir(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture
         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.tomlDir = string(tmp.Folder);
      end
   end

   methods (Access = private)
      function file = writeToml(testCase, lines)
         file = char(fullfile(testCase.tomlDir, "fixture.toml"));
         writelines(lines, file)
      end
   end

   methods (Test)
      function testSectionsAndScalars(testCase)
         file = testCase.writeToml([ ...
            "# full-line comment"; ...
            "[project]"; ...
            "name = ""alpha""  # trailing comment"; ...
            "count = 3"; ...
            "enabled = true"; ...
            "disabled = false"]);
         returned = readtoml(file);
         testCase.verifyEqual(returned.project.name, 'alpha')
         testCase.verifyEqual(returned.project.count, 3)
         testCase.verifyTrue(returned.project.enabled)
         testCase.verifyFalse(returned.project.disabled)
      end

      function testDottedSectionAndArrays(testCase)
         file = testCase.writeToml([ ...
            "[deps.inner]"; ...
            "names = [""a"", ""b""]"; ...
            "none = []"]);
         returned = readtoml(file);
         expected = {'a', 'b'};
         testCase.verifyEqual(returned.deps.inner.names, expected)
         testCase.verifyEmpty(returned.deps.inner.none)
      end

      function testHashInsideStringIsLiteral(testCase)
         file = testCase.writeToml("title = ""a # not a comment""");
         returned = readtoml(file);
         expected = 'a # not a comment';
         testCase.verifyEqual(returned.title, expected)
      end

      function testMissingFileErrors(testCase)
         testCase.verifyError( ...
            @() readtoml(fullfile(testCase.tomlDir, "nope.toml")), ...
            'matfunclib:readtoml:fileNotFound')
      end

      function testMalformedSectionErrors(testCase)
         file = testCase.writeToml("[unclosed");
         testCase.verifyError(@() readtoml(file), ...
            'matfunclib:readtoml:badSection')
      end

      function testKeylessLineErrors(testCase)
         file = testCase.writeToml("just some words");
         testCase.verifyError(@() readtoml(file), ...
            'matfunclib:readtoml:badLine')
      end

      function testInvalidNameErrors(testCase)
         file = testCase.writeToml("bad-key = ""x""");
         testCase.verifyError(@() readtoml(file), ...
            'matfunclib:readtoml:badName')
      end

      function testUnterminatedStringErrors(testCase)
         file = testCase.writeToml("key = ""open");
         testCase.verifyError(@() readtoml(file), ...
            'matfunclib:readtoml:badValue')
      end

      function testMultilineArrayRejected(testCase)
         file = testCase.writeToml(["list = [""a"","; """b""]"]);
         testCase.verifyError(@() readtoml(file), ...
            'matfunclib:readtoml:badValue')
      end

      function testUnquotedArrayElementRejected(testCase)
         file = testCase.writeToml("list = [abc]");
         testCase.verifyError(@() readtoml(file), ...
            'matfunclib:readtoml:badValue')
      end

      function testUnsupportedValueRejected(testCase)
         file = testCase.writeToml("when = 1979-05-27T07:32:00Z");
         testCase.verifyError(@() readtoml(file), ...
            'matfunclib:readtoml:badValue')
      end

      function testTripleQuotedStringRejected(testCase)
         % Embedded quotes are outside the subset and must not return a
         % corrupted value.
         file = testCase.writeToml("title = """"""hello""""""");
         testCase.verifyError(@() readtoml(file), ...
            'matfunclib:readtoml:badValue')
      end

      function testKeySectionCollisionsRejected(testCase)
         % A key overwriting a table, and a section reopening a key, both
         % fail fast instead of dropping data.
         file = testCase.writeToml([ ...
            "[a.b]"; "x = 1"; "[a]"; "b = ""scalar now"""]);
         testCase.verifyError(@() readtoml(file), ...
            'matfunclib:readtoml:nameCollision')
         file = testCase.writeToml(["[a]"; "b = 1"; "[a.b]"; "x = 1"]);
         testCase.verifyError(@() readtoml(file), ...
            'matfunclib:readtoml:nameCollision')
      end

      function testEmptyValueRejected(testCase)
         file = testCase.writeToml("key =");
         testCase.verifyError(@() readtoml(file), ...
            'matfunclib:readtoml:badValue')
      end
   end
end
