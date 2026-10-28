# Mandatory stops

Used by: `implement-task`, `refactor`, `bug-fix`, `step-agent`.

A **tactical** decision is one with more than one reasonable approach that changes neither a contract, the architecture nor observable behavior.

| Mode | Behavior |
|---|---|
| **AFK** | Runs autonomously from start to finish, deciding tactical questions on its own |
| **HITL** | Also pauses at tactical decisions |

In **both modes**, you must stop and wait for the user at:

- Removal of an entire file
- Architectural decisions → read `{root}/.claude/docs/templates/adr-template.md` and present it to the user
- Installing or updating an external package
- A breaking change to a module's public interface
- Any irreversible action

A subagent has no way to wait for the user: at these points it stops and returns a gate to the orchestrator, in the format defined in the agent itself.
