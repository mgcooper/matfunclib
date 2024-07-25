function plan = buildfile

   % Create a plan from the task functions
   plan = buildplan(localfunctions);

   % Make the "test" task the default task in the plan
   plan.DefaultTasks = "test";

   % Make the "release" task dependent on the "check" and "test" tasks
   plan("release").Dependencies = ["check" "test"];

   % Notes: buildplan accepts a cell vector of function handles. So you can send
   % localfunctions to it, or something like this:
   % buildplan({@compileTask, @testTask})
   %
   % Task functions are local functions in the build file whose names end with
   % the word "Task", which is case insensitive. A task function must accept a
   % TaskContext object as its first input, even if the task ignores it.
   %
   % The build tool generates task names from task function names by removing
   % the "Task" suffix. For example, a task function testTask results in a task
   % named "test". Additionally, the build tool treats the first help text line,
   % often called the H1 line, of the task function as the task description. The
   % code in the task function corresponds to the action performed when the task
   % runs.
   %
   % I am not sure if projectfile can be adapted using buildplan

end

function checkTask(~)
   % Identify code issues
   issues = codeIssues;
   assert(isempty(issues.Issues),formattedDisplayText( ...
      issues.Issues(:,["Location" "Severity" "Description"])))
end

function testTask(~)
   % Run unit tests
   results = runtests(IncludeSubfolders=true, OutputDetail="terse");
   assertSuccess(results);
end

function releaseTask(~)
   % Create toolbox release

   releaseFolderName = "release";
   % Create a release and put it in the release directory
   opts = matlab.addons.toolbox.ToolboxOptions("toolboxPackaging.prj");

   % By default, the packaging GUI restricts the name of the getting started
   % guide, so we fix that here.
   opts.ToolboxGettingStartedGuide = fullfile("toolbox", "gettingStarted.mlx");

   % GitHub releases don't allow spaces, so replace spaces with underscores
   mltbxFileName = strrep(opts.ToolboxName," ","_") + ".mltbx";
   opts.OutputFile = fullfile(releaseFolderName, mltbxFileName);

   % Create the release directory, if needed
   if ~exist(releaseFolderName, "dir")
      mkdir(releaseFolderName)
   end

   % Package the toolbox
   matlab.addons.toolbox.packageToolbox(opts);
end
