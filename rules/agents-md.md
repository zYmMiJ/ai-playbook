# `AGENTS.md` + `CLAUDE.md` : une seule source d'instructions

Convention éprouvée sur plusieurs repos d'un même produit (back, front, infra) quand plus d'un outil
IA lit le projet (Claude Code, Codex, autre agent) : les instructions du projet ne sont écrites
**qu'une fois**, dans `AGENTS.md`, et `CLAUDE.md` ne fait que l'importer.

## Structure

`AGENTS.md` — tout ce qui vaut pour n'importe quel agent : stack, lancer en local, tests,
conventions, pièges, renvois vers `docs/`. Commence par la même consigne que n'importe quel
`CLAUDE.md` : *ne documenter que ce qui n'est pas déductible d'une lecture rapide du code.*

`CLAUDE.md` — l'import, puis uniquement ce qui est propre à Claude Code :

```markdown
@AGENTS.md

## Claude Code

- Les instructions du projet sont dans `AGENTS.md` (partagé avec les autres outils IA) ; n'ajouter
  ici que ce qui est propre à Claude Code.
- `.claude/skills`, `.claude/agents` et `.claude/hooks` : n'y ajouter un skill, un agent ou un hook
  que pour un besoin déjà identifié, pas par anticipation. `.claude/settings.local.json` est
  personnel et ignoré par git.
```

Typiquement propre à Claude Code : la liste des skills copiés depuis ce playbook, les hooks, les
consignes de contexte (voir [`context-efficiency.md`](context-efficiency.md)).

## Pourquoi

- Deux fichiers d'instructions écrits en parallèle divergent vite — une convention corrigée dans
  l'un et pas dans l'autre, et les deux outils ne travaillent plus avec les mêmes règles.
- L'import `@AGENTS.md` est résolu par Claude Code au chargement : aucune duplication à maintenir.
- `.claude/` vide par défaut (un `.gitkeep` suffit) : un skill/agent ajouté "au cas où" coûte du
  contexte à chaque session et vieillit sans que personne ne s'en serve.

## Quand ne pas l'appliquer

Si un outil n'intervient que dans un périmètre étroit (ex. Codex uniquement en CI, comme sur ce
repo), son `AGENTS.md` décrit **ce périmètre-là** et `CLAUDE.md` reste la source principale — pas
d'import dans ce cas, les deux fichiers n'ont pas le même public.
