# Project-specific code style — matfunclib

Conventions specific to matfunclib, extending the canonical `STYLE.md` (general +
MATLAB). This file is project-owned — `--update` never overwrites it.

## Naming

Follows the canonical rule (short all-lowercase, camelCase when a name gets too long).
No matfunclib-specific override.

## Idioms and patterns

- Use `arguments` blocks for new functions.
- Preserve backward compatibility for widely-used helpers unless there is a clear
  reason to break it.
- For functions that are old but heavily reused, favor incremental improvement over
  large rewrites.
