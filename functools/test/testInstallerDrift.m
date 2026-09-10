classdef testInstallerDrift < matlab.unittest.TestCase
   %TESTINSTALLERDRIFT Drift detection for the installRequiredFiles copies.
   %
   % The canonical installer is functools/installRequiredFiles.m. The
   % template copy at toolbox/toolbox/+tbx/+internal/installRequiredFiles.m
   % must equal it modulo one documented carve-out: the bootstrapped
   % projectpath()/toolboxpath() default resolution and the docstring
   % sentences that describe it. The private helpers undersource.m and
   % foldscase.m stamped beside the template must equal their functools
   % originals byte for byte.
   %
   % The suite compares the stamped consumer copies (activelayer, grace,
   % groupstats, hydrobasins, icemodel, merra2, nid) the same way and
   % prints their deltas as a diagnostic report. That report never fails a
   % test: matfunclib-juq.12 re-stamps those copies and enforces zero drift
   % afterwards (matfunclib-juq.46).
   %
   % Drift is measured on ordered line sequences. Two files agree only when
   % they hold the same lines in the same order and count; only trailing
   % blank lines are ignored. Applying the carve-out to the canonical text
   % gives the expected template text. The template copy must equal that
   % text. A consumer copy passes the diagnostic when it equals either the
   % canonical text or that expected template.

   properties (Constant)
      % The carve-out, as ordered pairs of canonical lines and the template
      % lines that stand in for them. Every pair is a contiguous block, so
      % the substitution matches whole blocks. Redesign DesignSpec
      % acceptance lines 662-670 name this carve-out.
      CarveOut = { ...
         [ ...
         "   %  REQUIREMENTSFILE when one is supplied; otherwise PROJECTPATH becomes"; ...
         "   %  required, and the requirements for all files in the PROJECTPATH folder"; ...
         "   %  are installed."; ...
         "   %"; ...
         "   %  PROJECTPATH - (optional, name-value) a full path (scalar text) to a"; ...
         "   %  folder. Requirements for all files within this folder are generated and"; ...
         "   %  installed into the folder. The default install location is a subfolder"; ...
         "   %  named ""dependencies"" at the top level of PROJECTPATH. Specify the optional"; ...
         "   %  INSTALLPATH argument to control where dependencies are installed."], ...
         [ ...
         "   %  REQUIREMENTSFILE when one is supplied; otherwise the requirements for"; ...
         "   %  all files in the PROJECTPATH folder are installed."; ...
         "   %"; ...
         "   %  PROJECTPATH - (optional, name-value) a full path (scalar text) to a"; ...
         "   %  folder. Requirements for all files within this folder are generated and"; ...
         "   %  installed. In this bootstrapped-toolbox copy the default PROJECTPATH is"; ...
         "   %  the project root resolved by projectpath(), and the default install"; ...
         "   %  location is the ""dependencies"" subfolder of the toolbox folder resolved"; ...
         "   %  by toolboxpath(). Specify the optional INSTALLPATH argument to control"; ...
         "   %  where dependencies are installed."]; ...
         [ ...
         "   %  NOTE: If none of the three arguments above are supplied, the default"; ...
         "   %  behavior uses the current working directory as the PROJECTPATH parameter,"; ...
         "   %  and the function proceeds as though PROJECTPATH were supplied."], ...
         [ ...
         "   %  NOTE: If none of the three arguments above are supplied, the default"; ...
         "   %  behavior installs the requirements of the project root resolved by"; ...
         "   %  projectpath() into the toolbox ""dependencies"" folder resolved by"; ...
         "   %  toolboxpath()."]; ...
         [ ...
         "   %  INSTALLPATH - full path to location where files are installed. The default"; ...
         "   %  value is a folder named ""dependencies"" in the PROJECTPATH."], ...
         [ ...
         "   %  INSTALLPATH - full path to location where files are installed. The default"; ...
         "   %  value is a folder named ""dependencies"" in the toolbox folder."]; ...
         "         = pwd()", ...
         "         = projectpath()"; ...
         [ ...
         "      % if installPath is supplied dependencies are installed there. If it is"; ...
         "      % not supplied dependencies are installed to projectPath/dependencies."], ...
         [ ...
         "      % installPath default is derived in parseargs (the toolbox"; ...
         "      % ""dependencies"" folder); the """" sentinel distinguishes ""not supplied"""; ...
         "      % from an explicit path."]; ...
         [ ...
         "   % Derive the documented installPath default (""dependencies"" inside"; ...
         "   % PROJECTPATH) when the caller did not supply one. A caller's path is"; ...
         "   % resolved like the others, so a relative one that does not exist yet"; ...
         "   % is fixed to the caller's folder before it is probed or created."; ...
         "   if strlength(kwargs.installPath) == 0"; ...
         "      installPath = fullfile(projectPath, ""dependencies"");"], ...
         [ ...
         "   % Derive the documented installPath default (the toolbox ""dependencies"""; ...
         "   % folder) when the caller did not supply one. This bootstrapped-copy"; ...
         "   % default intentionally differs from the matfunclib canonical, which"; ...
         "   % derives it from PROJECTPATH. A caller's path is resolved like the"; ...
         "   % others, so a relative one that does not exist yet is fixed to the"; ...
         "   % caller's folder before it is probed or created."; ...
         "   if strlength(kwargs.installPath) == 0"; ...
         "      installPath = fullfile(toolboxpath(), ""dependencies"");"] ...
         }

      % The template's private getRequiredFiles.m differs from
      % functools/getRequiredFiles.m by one comment line above the
      % requirementsFileName argument. That line is its whole carve-out.
      GetRequiredFilesCarveOut = { ...
         "      kwargs.requirementsFileName (1, 1) string {mustBeTextScalar} = """"", ...
         [ ...
         "      % """" defers the default; see REQUIREMENTSFILENAME in the header."; ...
         "      kwargs.requirementsFileName (1, 1) string {mustBeTextScalar} = """""] ...
         }

      % The stamped consumer copies, relative to the projects folder that
      % holds matfunclib. The suite reports each one and asserts none.
      ConsumerCopies = [ ...
         "activelayer/toolbox/+activelayer/+internal/installRequiredFiles.m"; ...
         "grace/toolbox/+grace/+internal/installRequiredFiles.m"; ...
         "groupstats/toolbox/+groupstats/+internal/installRequiredFiles.m"; ...
         "hydrobasins/toolbox/+hydrobasins/+internal/installRequiredFiles.m"; ...
         "icemodel/icemodel/+icemodel/+internal/installRequiredFiles.m"; ...
         "merra2/toolbox/+merra/+internal/installRequiredFiles.m"; ...
         "nid/toolbox/+nid/+internal/installRequiredFiles.m"]
   end

   properties
      % Repository root and the two files under test, resolved at setup.
      repoRoot string
      canonicalFile string
      templateFile string
   end

   methods (TestClassSetup)
      function resolveFiles(testCase)
         import matlab.unittest.fixtures.PathFixture

         % The detector reads files and calls no installer, but every
         % class suite adds the project to the path (STYLE.local.md) so it
         % runs from the repo root like the others.
         testFolder = fileparts(mfilename("fullpath"));
         testCase.applyFixture(PathFixture( ...
            fileparts(fileparts(testFolder)), "IncludingSubfolders", true));
         testCase.repoRoot = string(fileparts(fileparts(testFolder)));
         testCase.canonicalFile = fullfile(testCase.repoRoot, ...
            "functools", "installRequiredFiles.m");
         testCase.templateFile = fullfile(testCase.repoRoot, ...
            "toolbox", "toolbox", "+tbx", "+internal", ...
            "installRequiredFiles.m");
      end
   end

   methods (Static)
      function lines = expectedTemplate(canonicalLines, pairs)
         %EXPECTEDTEMPLATE Apply the carve-out to the canonical lines.
         %
         % Each pair is matched as a contiguous block. A pair that does not
         % match raises an error, because a stale carve-out would otherwise
         % pass as "no template drift" with no message. PAIRS defaults to
         % the installer carve-out.
         if nargin < 2
            pairs = testInstallerDrift.CarveOut;
         end
         lines = canonicalLines(:);
         for n = 1:size(pairs, 1)
            old = pairs{n, 1}(:);
            new = pairs{n, 2}(:);
            start = testInstallerDrift.findBlock(lines, old);
            if isempty(start)
               error('installerDrift:staleCarveOut', ...
                  'carve-out pair %d does not match the canonical text', n)
            end
            lines = [lines(1:start - 1); new; lines(start + numel(old):end)];
         end
      end

      function start = findBlock(lines, block)
         %FINDBLOCK Index of the first contiguous occurrence of BLOCK.
         start = [];
         m = numel(block);
         for k = 1:numel(lines) - m + 1
            if isequal(lines(k:k + m - 1), block)
               start = k;
               return
            end
         end
      end

      function residual = drift(copyLines, baseLines)
         %DRIFT Difference between two files as ordered line sequences.
         %
         % RESIDUAL has zero rows only when the two sequences are equal
         % line for line. Only trailing blank lines are dropped, so a stray
         % newline at the end of a file is not drift while an internal
         % blank line is. Otherwise RESIDUAL is a string column for the
         % report: lines only in the copy prefixed "+ ", and lines only in
         % the base prefixed "- ". When the two hold the same lines in a
         % different order or count, RESIDUAL is one "~" row that says so,
         % because a set difference cannot show that.
         copyLines = testInstallerDrift.droptrailingblanks(copyLines);
         baseLines = testInstallerDrift.droptrailingblanks(baseLines);
         if isequal(copyLines, baseLines)
            residual = strings(0, 1);
            return
         end
         onlyInCopy = setdiff(copyLines(strlength(copyLines) > 0), ...
            baseLines(strlength(baseLines) > 0));
         onlyInBase = setdiff(baseLines(strlength(baseLines) > 0), ...
            copyLines(strlength(copyLines) > 0));
         residual = [reshape("+ " + onlyInCopy, [], 1); ...
            reshape("- " + onlyInBase, [], 1)];
         if isempty(residual)
            residual = sprintf("~ same lines in a different order or " + ...
               "count (%d lines in the copy, %d in the base)", ...
               numel(copyLines), numel(baseLines));
         end
      end

      function lines = droptrailingblanks(lines)
         %DROPTRAILINGBLANKS A column of LINES without its trailing blank
         % (or whitespace-only) lines; internal blank lines stay.
         lines = reshape(lines, [], 1);
         last = find(strlength(strtrim(lines)) > 0, 1, "last");
         lines = lines(1:last);
      end

      function residual = driftFromTemplate(copyLines, canonicalLines)
         %DRIFTFROMTEMPLATE Ordered residual against the template text with
         % the carve-out applied. The template copy must carry the
         % carve-out, so a copy identical to the canonical is drift here.
         residual = testInstallerDrift.drift(copyLines, ...
            testInstallerDrift.expectedTemplate(canonicalLines));
      end

      function residual = driftModuloCarveOut(copyLines, canonicalLines)
         %DRIFTMODULOCARVEOUT The smaller ordered residual against the
         % canonical or against the template text, for a consumer copy
         % that may carry either form. Zero rows means the copy differs
         % from the canonical only inside the carve-out, or not at all.
         againstCanonical = testInstallerDrift.drift(copyLines, ...
            canonicalLines);
         againstTemplate = testInstallerDrift.driftFromTemplate( ...
            copyLines, canonicalLines);
         if numel(againstTemplate) <= numel(againstCanonical)
            residual = againstTemplate;
         else
            residual = againstCanonical;
         end
      end
   end

   methods (Test)
      function testTemplateCopyMatchesCanonicalModuloCarveOut(testCase)
         % The real template copy equals the canonical with the carve-out
         % applied, line for line and in order.
         canonical = readlines(testCase.canonicalFile);
         template = readlines(testCase.templateFile);
         returned = testInstallerDrift.driftFromTemplate(template, ...
            canonical);
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected, ...
            "template drift: " + strjoin(returned, newline))
      end

      function testTemplateWithoutCarveOutIsDrift(testCase)
         % A template re-stamped byte for byte from the canonical has lost
         % its projectpath()/toolboxpath() defaults, so it is drift.
         canonical = readlines(testCase.canonicalFile);
         returned = any(contains(testInstallerDrift.driftFromTemplate( ...
            canonical, canonical), "toolboxpath()"));
         expected = true;
         testCase.verifyEqual(returned, expected)
      end

      function testReorderedLinesAreDrift(testCase)
         % The same lines in a different order, or one repeated line fewer,
         % are drift even though the line sets are equal.
         canonical = readlines(testCase.canonicalFile);
         copy = testInstallerDrift.expectedTemplate(canonical);
         idx = find(copy == "end", 2);
         returned = numel(idx);
         expected = 2;
         testCase.assertEqual(returned, expected)
         swapped = copy([1:idx(1) - 1, idx(1) + 1:idx(2) - 1, idx(1), idx(2):end]);
         residual = testInstallerDrift.driftFromTemplate(swapped, canonical);
         returned = [numel(residual), startsWith(residual(1), "~")];
         expected = [1, true];
         testCase.verifyEqual(returned, expected)

         fewer = copy([1:idx(1) - 1, idx(1) + 1:end]);
         residual = testInstallerDrift.driftFromTemplate(fewer, canonical);
         returned = [numel(residual), startsWith(residual(1), "~")];
         expected = [1, true];
         testCase.verifyEqual(returned, expected)
      end

      function testTemplateGetRequiredFilesMatchesCanonicalModuloCarveOut(testCase)
         % The template's private getRequiredFiles.m equals the canonical
         % with its one-line carve-out applied, line for line.
         canonical = readlines(fullfile(testCase.repoRoot, "functools", ...
            "getRequiredFiles.m"));
         template = readlines(fullfile(testCase.repoRoot, "toolbox", ...
            "toolbox", "+tbx", "+internal", "private", "getRequiredFiles.m"));
         returned = testInstallerDrift.drift(template, ...
            testInstallerDrift.expectedTemplate(canonical, ...
            testInstallerDrift.GetRequiredFilesCarveOut));
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected, ...
            "getRequiredFiles drift: " + strjoin(returned, newline))
      end

      function testTemplateUndersourceIsByteIdentical(testCase)
         % The private helper stamped beside the template is the functools
         % file, byte for byte.
         expected = fileread(fullfile(testCase.repoRoot, "functools", ...
            "undersource.m"));
         returned = fileread(fullfile(testCase.repoRoot, "toolbox", ...
            "toolbox", "+tbx", "+internal", "private", "undersource.m"));
         testCase.verifyEqual(returned, expected)
      end

      function testFoldscaseCopyIsByteIdentical(testCase)
         % The private helper stamped beside the template is the functools
         % file, byte for byte.
         expected = fileread(fullfile(testCase.repoRoot, "functools", ...
            "foldscase.m"));
         returned = fileread(fullfile(testCase.repoRoot, "toolbox", ...
            "toolbox", "+tbx", "+internal", "private", "foldscase.m"));
         testCase.verifyEqual(returned, expected)
      end

      function testFixtureIdenticalCopyReportsNoDrift(testCase)
         % A byte-identical copy of the canonical has zero residual.
         canonical = readlines(testCase.canonicalFile);
         returned = testInstallerDrift.driftModuloCarveOut(canonical, ...
            canonical);
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
      end

      function testFixtureCarveOutOnlyDeltaReportsNoDrift(testCase)
         % A copy that differs only by the carve-out has zero residual, and
         % the carve-out is a real change (the copy is not the canonical).
         canonical = readlines(testCase.canonicalFile);
         copy = testInstallerDrift.expectedTemplate(canonical);
         returned = isequal(copy, canonical(:));
         expected = false;
         testCase.verifyEqual(returned, expected)
         returned = testInstallerDrift.driftModuloCarveOut(copy, canonical);
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
      end

      function testFixtureStructuralDeltaIsReported(testCase)
         % A copy with one code line changed outside the carve-out is
         % reported with that one line, in both directions.
         canonical = readlines(testCase.canonicalFile);
         copy = testInstallerDrift.expectedTemplate(canonical);
         idx = find(copy == "      kwargs.dryrun (1, 1) logical {mustBeNumericOrLogical} ...", 1);
         returned = isempty(idx);
         expected = false;
         testCase.assertEqual(returned, expected)
         copy(idx) = "      kwargs.testRun (1, 1) logical {mustBeNumericOrLogical} ...";
         returned = testInstallerDrift.driftModuloCarveOut(copy, canonical);
         expected = [ ...
            "+       kwargs.testRun (1, 1) logical {mustBeNumericOrLogical} ..."; ...
            "-       kwargs.dryrun (1, 1) logical {mustBeNumericOrLogical} ..."];
         testCase.verifyEqual(returned, expected)
      end

      function testInternalBlankLineIsDrift(testCase)
         % Removing an internal blank line is drift; a trailing newline is
         % not.
         canonical = readlines(testCase.canonicalFile);
         copy = testInstallerDrift.expectedTemplate(canonical);
         blank = find(strlength(strtrim(copy)) == 0, 1);
         returned = isempty(blank);
         expected = false;
         testCase.assertEqual(returned, expected)
         returned = isempty(testInstallerDrift.driftFromTemplate( ...
            copy([1:blank - 1, blank + 1:end]), canonical));
         expected = false;
         testCase.verifyEqual(returned, expected)

         returned = testInstallerDrift.driftFromTemplate( ...
            [copy; ""; ""], canonical);
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
      end

      function testStaleCarveOutIsAnError(testCase)
         % When the canonical text lacks a carve-out block, the detector
         % raises an error and does not report zero drift.
         canonical = readlines(testCase.canonicalFile);
         canonical(canonical == "         = pwd()") = "         = cd()";
         testCase.verifyError( ...
            @() testInstallerDrift.expectedTemplate(canonical), ...
            'installerDrift:staleCarveOut')
      end

      function testLiveConsumerCopiesAreReportedDiagnostically(testCase)
         % The test compares each reachable stamped consumer copy and prints
         % its residual. This is a report, not an assertion: known drift in
         % icemodel, nid, and groupstats must not fail the suite.
         canonical = readlines(testCase.canonicalFile);
         projects = fileparts(testCase.repoRoot);
         fprintf(1, "\n=== installRequiredFiles drift report (diagnostic) ===\n");
         for n = 1:numel(testInstallerDrift.ConsumerCopies)
            rel = testInstallerDrift.ConsumerCopies(n);
            file = fullfile(projects, rel);
            if ~isfile(file)
               fprintf(1, "%s: unreachable (no file)\n", rel);
               continue
            end
            residual = testInstallerDrift.driftModuloCarveOut( ...
               readlines(file), canonical);
            if isempty(residual)
               fprintf(1, "%s: identical modulo carve-out\n", rel);
            else
               fprintf(1, "%s: %d differing lines\n", rel, numel(residual));
               fprintf(1, "    %s\n", residual);
            end
         end
         fprintf(1, "=== end drift report ===\n\n");
         returned = true;
         expected = true;
         testCase.verifyEqual(returned, expected)
      end
   end
end
