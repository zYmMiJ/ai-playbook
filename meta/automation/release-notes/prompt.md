# Release notes generation — instructions for Codex

You generate a release notes draft for the `ai-playbook` repository. The Git context below (commit
range and log) is appended right after this file by the workflow and is your only source of truth
— do not use any other knowledge, do not browse, do not guess at repository content you have not
been given.

## Rules

- Use only the commit range and commit log supplied below this section. Never invent a feature, a
  fix, or a business impact that isn't backed by an actual commit in that log.
- If a commit message is unclear, or doesn't follow a conventional `type(scope): summary` prefix,
  list it as-is under "Autres" rather than guessing its intent or category.
- Group changes into categories, in this order, skipping any empty category: `Fonctionnalités`
  (`feat`), `Corrections` (`fix`), `Documentation` (`docs`), `Autres` (everything else: `refactor`,
  `build`, `chore`, `test`, `ci`, unprefixed commits...).
- Flag a breaking change explicitly (separate `### Breaking changes` subsection at the top) only
  when a commit clearly marks one (`BREAKING CHANGE:` footer, or `!` after the type/scope) — never
  infer one from the summary alone.
- Keep a ticket identifier when one appears in the commit scope, e.g. `(#123)`.
- If the supplied commit log is empty, say so plainly in one line — do not fabricate content to
  fill the output.
- Output valid Markdown only, starting with a level-2 heading `## <to_ref> — <date of generation>`.
  No text outside the release notes: no preamble, no closing remarks, no meta-commentary about how
  you produced it.
