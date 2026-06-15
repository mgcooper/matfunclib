# Project-specific code style — matfunclib

Conventions specific to matfunclib, extending the canonical `STYLE.md` (general +
MATLAB). This file is project-owned — `--update` never overwrites it.

## Naming

Follows the canonical rule (short all-lowercase, camelCase when a name gets too long).
No matfunclib-specific override.

## Formatting

- Indent with 3 spaces; no tabs.
- Wrap lines around 80 columns; continue with `...` and indent the continuation.
- Close every function with an explicit `end` (do not rely on implicit end-of-file).

## Idioms and patterns

- Use `arguments` blocks for new functions.
- Preserve backward compatibility for widely-used helpers unless there is a clear
  reason to break it.
- For functions that are old but heavily reused, favor incremental improvement over
  large rewrites.

## Tests

- Each library has its own `test/` folder.
- Write new tests as class-based suites (`classdef … < matlab.unittest.TestCase`),
  with the file named `testCamelCase.m`. The older function-based
  `functiontests(localfunctions)` suites in `test_name.m` files remain valid but
  are legacy.
- Add the project to the path inside `TestClassSetup` with a `PathFixture` (see
  `liblogic/test/testBlankTextHelpers.m`) so the suite runs from the repo root
  without manual path setup.
