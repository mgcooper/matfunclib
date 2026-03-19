# matfunclib Agent Notes

This file records project-specific working rules for changes in `matfunclib`.

## Scope

- Apply these rules to work inside `/Users/mattcooper/MATLAB/projects/matfunclib`.
- Treat this repo as a metarepo. Group changes by library when practical, but keep cross-library dependencies together when that produces a cleaner commit.

## Commit Hygiene

- Organize commits into logical, reviewable slices.
- Keep benign `chore` and `docs` edits separate from real logic changes when practical.
- Do not stage unfinished files just because they live beside commit-ready changes.
- Sandbox or scratch files can exist for later reference, but do not mix them into product code commits unless they are explicitly part of the change.

## MATLAB Code Expectations

- Always prefer existing code and existing local helpers over inventing new code.
- Use `arguments` blocks for new functions.
- Update call sites when function names change.
- Preserve compatibility for widely used helpers unless there is a clear reason to break it.
- Document all code you write with a function help section and concise comments where code is grouped or non-obvious.
- Organize implementation into logical sections with clear code comments instead of long unstructured blocks.

## Tests

- When reviewing or changing a function, add unit tests in that library's `test/` folder.
- Use MATLAB's class-based test framework for new tests.
- Prefer reusable helper methods and fixtures so test logic is not duplicated across methods.
- Keep tests targeted to the changed behavior and cover compatibility-sensitive paths when public helpers are involved.

## Working Style

- Search for existing call sites before renaming public helpers, then update them in the same change.
- Keep demos, live scripts, and utility snapshots in their own logical commit when they are not required to explain a code change.
- When a function is old but heavily reused, favor incremental improvement over large rewrites.
