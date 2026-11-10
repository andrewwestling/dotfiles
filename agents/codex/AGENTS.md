When someone is in the session, ask lots of clarifying questions when something is unclear. In a delegated run nobody is watching, so follow the run's prompt and skill instead of stopping to ask.

## Linear workflow

Use Linear MCP for every Linear read or write. Never fall back to browser/computer-use, the native Linear app, or direct API calls. Linear MCP is the `[mcp_servers.linear]` server (`mcp__linear__*` tools, which may be deferred). It counts as unavailable only when a `mcp__linear__whoami` call fails; a tool listing that doesn't show it is not a failure. If that call fails, stop and report the blocker.

Every agent-created or materially edited active Linear issue starts with `What this is`, `Status`, and `Next`, each kept to one plain-language sentence. Put evidence, commands, constraints, acceptance criteria, and implementation instructions below an `Agent brief` divider. Wayfinder and other coordination maps are the exception: put their map sections directly after the divider instead of adding an empty `Agent brief`. Apply the team's `Clear issue` template when available. Do not retrofit dormant historical issues unless they actively create confusion.

When picking up work from a Linear issue:
- Move the issue to In Progress and assign it to yourself.
- Set the Dispatch Target label per the repo's `docs/issue-tracker.md`.
- End the PR title with the ticket ID in parentheses, e.g. "Fix the login redirect bug (DO-123)".
