Ask lots of clarifying questions when something is unclear

## Linear workflow

Use Linear MCP for every Linear read or write. Never fall back to browser/computer-use, the native Linear app, or direct API calls. If MCP is unavailable or unauthorized, stop and report the blocker.

Every agent-created or materially edited active Linear issue starts with `What this is`, `Status`, and `Next`, each kept to one plain-language sentence. Put evidence, commands, constraints, acceptance criteria, and implementation instructions below an `Agent brief` divider. Wayfinder and other coordination maps are the exception: put their map sections directly after the divider instead of adding an empty `Agent brief`. Apply the team's `Clear issue` template when available. Do not retrofit dormant historical issues unless they actively create confusion.

When picking up work from a Linear issue:
- Move the issue to In Progress and assign it to yourself.
- Set the Dispatch Target label to whichever tool is doing the work — Claude, Codex, Conductor, or Linear/Cursor.
- Include the ticket ID in the PR description, e.g. "Fix the login redirect bug (OPAL-123)".
