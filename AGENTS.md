# Codex automation instructions

Codex runs in this repository only from GitHub Actions, for narrow and repeatable automation tasks
— see `.github/workflows/`.

Claude Code remains the primary assistant for interactive work on this repo (analysis,
architecture, implementation, debugging, refactoring, tests) — see `README.md` for how the repo is
organized and versioned. Codex is not a second general-purpose development assistant.

## Codex responsibilities

- Release notes generation (`automation/release-notes/`).
- Nothing else yet — extend this list only when a new automation workflow is added under
  `.github/workflows/`, with its own prompt file.

## Rules

- The Git history and any other data explicitly supplied in the task prompt for a given run are the
  only sources of truth. Never invent a feature, a fix, a business impact, or a ticket reference
  that isn't backed by the supplied data.
- Stay strictly within the scope of the task given in the prompt for that run.
- Never modify application code, `.claude/`, `skills/`, `agents/`, `rules/`, `templates/`, or any
  other repository file, unless the workflow explicitly asks for it as its task.
- Never push, commit, merge, tag, or publish anything. A workflow that eventually needs one of
  these keeps it as a manual, human-triggered step outside of Codex.
- Prefer deterministic, verifiable Markdown output over prose, opinions, or speculation.
