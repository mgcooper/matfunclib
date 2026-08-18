# MATLAB Toolbox

- Look things over generally
- Update userhooks
- Run tests, fix any bad namespace references or failed +internal methods
- Update gettingStarted.mlx
- Run projectfile when ready
- Delete _Contents.m and run tbx.internal.makecontents
- Delete _toolboxPackaging; `releasefile` packages the toolbox (see Build
  workflow below), so no packaging prj is made by hand

## Build workflow

One project uses four build files. All of them run headless.

- `mproject.toml` declares the project's dependencies (projects and
  toolboxes by the names in the manager's project and toolbox
  directories). It is the one declared source: `workon`
  resolves it at activation and the Project generator derives
  Referenced Projects from it. It never lists files.
- `projectfile.m` (project root) creates or updates the MATLAB Project
  through manager's `createMatlabProject`, which imports the toolbox
  folder, generates Referenced Projects from the manifest, and can sync
  missing required files into the Project.
- `buildfile.m` (project root) is the `buildtool` plan: `check` (zero
  code issues over `toolbox/` and `test/`), `test` (the suites in
  `test/`), `contents` (regenerate Contents.m), and `release`. It must
  stay at the project root: `buildtool` discovers build files only in
  the current folder and its parents, so a nested copy scopes its tasks
  to the nested folder and reports success without checking the code.
- `releasefile.m` (project root) packages `toolbox/` into a versioned
  `.mltbx` under `release/`. Options come from
  `<namespace>.internal.releaseoptions`: the Project's embedded Package
  Toolbox task when one exists, otherwise constructed from the
  `toolbox/` folder with the deterministic `<sanitized>-<hash>-toolbox`
  identifier (stable across releases, distinct across project names).
  The version is always pinned from `version.txt`. `buildtool release`
  runs check and test first, then calls the same `releasefile`.

Two more concepts complete the project surface:

- `setupfile.m` (project root) adds the toolbox to the path for a user
  without manager or an open Project. The name is "setup", not
  "install", because a source checkout has no install step beyond the
  path (an `.mltbx` install is MATLAB's own Add-On mechanism).
- `userhooks/` holds project-specific startup behavior; environment
  and data-path setup belongs there, never in the build files.

To cut a release: update `toolbox/version.txt` (shipped with the
package so installed code reports its own version), run
`buildtool release`, and pick up the `.mltbx` from `release/`. The
manifest test in `test/` verifies what a release would ship without
packaging one.

## Getting Started

__ is a MATLAB&reg; toolbox for ... Thanks for checking it out. If you're just getting started, here's what we recommend:

* First, open the live script `gettingStarted.mlx` for instructions on installing the toolbox.
* Next, work through the tutorials in order (`toolbox/examples/example01.mlx`, ``toolbox/examples/example02.mlx`, etc).

To get more help:

* 

To contribute:

* Open an issue

To run the test suite:

* Tests are located in `tests/`

* The toolbox installation file is in `release/`

## Toolbox Features

This demonstrates a number of MATLAB features, including:

* [MATLAB Toolbox Best Practices](https://github.com/mathworks/toolboxdesign)
* [Argument Validation](https://www.mathworks.com/help/matlab/matlab_prog/function-argument-validation-1.html)
* [Custom Suggestions and Tab Completion](https://www.mathworks.com/help/matlab/matlab_prog/customize-code-suggestions-and-completions.html)
* [Toolbox Packaging](https://www.mathworks.com/help/matlab/matlab_prog/create-and-share-custom-matlab-toolboxes.html)
* [Namespaces](https://www.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html), also known as packages
* [Function-Based Unit Tests](https://www.mathworks.com/help/matlab/function-based-unit-tests.html)
* [MATLAB Apps](https://www.mathworks.com/help/matlab/gui-development.html)
* [Live Tasks](https://www.mathworks.com/help/matlab/develop-live-editor-tasks.html)
* [MATLAB Projects](https://www.mathworks.com/help/matlab/projects.html)
* [`buildtool`](https://www.mathworks.com/help/matlab/matlab_prog/overview-of-matlab-build-tool.html)

## Contributing

## License

The license is available in the License.txt file in this GitHub repository.
