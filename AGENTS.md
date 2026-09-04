# Codex automation instructions

Codex runs in this repository only from GitHub Actions, for narrow and repeatable automation tasks
— see `.github/workflows/`.

Claude Code remains the primary assistant for interactive work on this repo (analysis,
architecture, implementation, debugging, refactoring, tests) — see `README.md` for how the repo is
organized and versioned. Codex is not a second general-purpose development assistant.

## Codex responsibilities

- None currently active. Release notes generation (`meta/automation/release-notes/`) used to run
  through Codex ([issue #15](https://github.com/zYmMiJ/ai-playbook/issues/15)) but now runs as a
  plain deterministic script instead — see
  [issue #20](https://github.com/zYmMiJ/ai-playbook/issues/20) — because the task never actually
  needed a model (conventional-commit parsing, no creative generation). The setup below (API key,
  secret, security practices) is kept ready in `meta/automation/README.md` for whichever future
  automation genuinely needs an LLM.
- Extend this list only when a new automation workflow under `.github/workflows/` actually calls
  Codex, with its own prompt file.

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
