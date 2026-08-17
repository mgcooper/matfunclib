function plan = buildfile
   %BUILDFILE Build plan for the toolbox: check, test, contents, release.
   %
   % This file lives at the project root because buildtool discovers
   % build files only in the current folder and its parents. A buildfile
   % nested in a subfolder scopes its tasks to that subfolder, so check
   % and test pass green having checked nothing (matfunclib-juq.27).
   % Every task below scopes itself explicitly from the plan root.
   %
   % The file is namespace-generic: it discovers the shipped +namespace
   % under toolbox/ at run time, so the template stamps into projects
   % without edits.
   %
   % See also: releasefile, projectfile, setupfile

   % Create a plan from the task functions in this file.
   plan = buildplan(localfunctions);

   % Make the "test" task the default task in the plan.
   plan.DefaultTasks = "test";

   % A release must never package unchecked or untested code.
   plan("release").Dependencies = ["check" "test"];

   % Notes: buildplan accepts a cell vector of function handles, so
   % localfunctions works, as does an explicit list like
   % buildplan({@checkTask, @testTask}).
   %
   % Task functions are local functions in the build file whose names
   % end with the word "Task", which is case insensitive. A task
   % function must accept a TaskContext object as its first input, even
   % if the task ignores it.
   %
   % The build tool generates task names from task function names by
   % removing the "Task" suffix (testTask becomes the task "test"), and
   % treats the first help text line (the H1 line) of the task function
   % as the task description.
end

function checkTask(context)
   % Identify code issues
   %
   % Checks everything the toolbox ships plus the tests, scoped
   % explicitly from the plan root so the result is the same no matter
   % which folder buildtool was invoked from. The bar is zero issues.

   arguments
      context (1,1) matlab.buildtool.TaskContext
   end

   root = context.Plan.RootFolder;
   files = [
      listCodeFiles(fullfile(root, "toolbox"))
      listCodeFiles(fullfile(root, "test"))
      ];
   issues = codeIssues(files);
   assert(isempty(issues.Issues), formattedDisplayText( ...
      issues.Issues(:, ["Location" "Severity" "Description"])))
end

function testTask(context)
   % Run unit tests
   %
   % Runs the suites in test/, with the shipped toolbox/ folder on the
   % path so the namespace resolves without an installed toolbox.

   arguments
      context (1,1) matlab.buildtool.TaskContext
   end

   root = context.Plan.RootFolder;
   addpath(fullfile(root, "toolbox"))
   results = runtests(fullfile(root, "test"), ...
      IncludeSubfolders=true, OutputDetail="terse");
   assertSuccess(results);
end

function contentsTask(context)
   % Regenerate every Contents.m
   %
   % Run this after adding, renaming, or removing a function, so the
   % generated listings do not go stale.

   arguments
      context (1,1) matlab.buildtool.TaskContext
   end

   root = context.Plan.RootFolder;
   addpath(fullfile(root, "toolbox"))
   feval(shippednamespace(root) + ".internal.makecontents", "-nobackup");
end

function releaseTask(context)
   % Create toolbox release
   %
   % Delegates to releasefile at the project root, so the command line
   % entry (releasefile) and the build task package identically.

   arguments
      context (1,1) matlab.buildtool.TaskContext
   end

   root = context.Plan.RootFolder;

   % releasefile.m sits at the project root; cd there so it resolves no
   % matter which folder buildtool was invoked from.
   returnTo = cd(root);
   restore = onCleanup(@() cd(returnTo));
   releasefile();
end

function files = listCodeFiles(folder)
   % Return every analyzable code file under a folder (.m and .mlx, the
   % types codeIssues supports), as a string column, so live scripts
   % cannot bypass the check task.

   arguments
      folder (1,1) string
   end

   mfound = dir(fullfile(folder, "**", "*.m"));
   xfound = dir(fullfile(folder, "**", "*.mlx"));
   found = [mfound; xfound];
   files = string(fullfile({found.folder}, {found.name}))';
end
