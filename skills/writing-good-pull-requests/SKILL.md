---
name: writing-good-pull-requests
description: >
  Rédige et ouvre une pull/merge request en brouillon à partir de la branche courante. Se déclenche
  quand l'utilisateur demande d'"ouvrir une PR", "créer une merge request", "faire une pull
  request" pour la branche en cours. Ne committe, ne push, ni ne merge jamais — complète le skill
  `writing-good-commits` (qui s'arrête au message de commit), ne le remplace pas.
---

# Writing good pull requests

> Adapté de [`ai-driven-dev/framework`](https://github.com/ai-driven-dev/framework)
> (`plugins/aidd-vcs/skills/02-pull-request`), simplifié pour un usage sans système de mémoire
> projet dédié — voir la note d'adaptation en bas de fichier.

## Démarche

1. **Résoudre la branche de base.** Si le repo a une convention connue préfixe → base (ex.
   `hotfix/*` → `main`, le reste → `develop` — voir le `CLAUDE.md` du projet), l'appliquer. Sinon,
   utiliser la branche par défaut réelle du repo (`gh repo view --json defaultBranchRef -q
   .defaultBranchRef.name`), **ne jamais supposer `main` par défaut** sans l'avoir vérifiée.
2. **Rassembler le changement.** `git log <base>..HEAD --oneline` pour les commits, `git diff
   <base>...HEAD --stat` pour les fichiers touchés.
3. **Rédiger titre + corps depuis le diff**, pas depuis la seule demande de l'utilisateur — même
   principe que [`writing-good-commits`](../writing-good-commits/SKILL.md). Utiliser le template
   du repo s'il existe (`.github/PULL_REQUEST_TEMPLATE.md` ou équivalent GitLab), sinon le gabarit
   par défaut ci-dessous.
4. **Présenter titre, corps et base à l'utilisateur, attendre validation explicite** avant de créer
   quoi que ce soit — même règle que ne jamais committer sans demande explicite pour ce tour (voir
   [`../../rules/general-coding.md`](../../rules/general-coding.md)).
5. **Créer la requête, toujours en brouillon** (`gh pr create --draft ...`, ou `glab mr create
   --draft ...` sur GitLab) : à l'utilisateur de la promouvoir en "ready for review" quand il le
   décide. Appliquer un label de triage seulement s'il existe déjà sur le repo distant et qu'un
   mapping préfixe → label est établi — ne jamais en créer un nouveau à la volée. Retourner l'URL.

## Gabarit de corps par défaut (à défaut de template projet)

```markdown
## Type de changement
- [ ] Fonctionnalité
- [ ] Correction de bug
- [ ] Refactor
- [ ] Documentation
- [ ] Autre : ...

## Description
<!-- résumé concis, orienté fonctionnel -->

## Comportement
<!-- ce qui change côté utilisateur, en quelques puces -->

## Comment tester
<!-- étapes de vérification, sans le setup/l'installation -->
```

## Règles

- Ce skill ne committe, ne push, ni ne merge jamais — uniquement la création de la requête.
- Ne jamais supposer `main` comme base sans avoir vérifié la branche par défaut réelle du repo.
- Ne pas inventer un label de triage absent du repo distant.
- Le résumé porte sur le **pourquoi fonctionnel** du changement, pas une reformulation de la liste
  des fichiers touchés — même défaut à éviter que pour un message de commit.

## Note d'adaptation

La version source résout l'outil VCS (`gh`/`glab`/...) et la convention branche→base depuis un
fichier de mémoire projet (`aidd_docs/memory/vcs.md`) propre au framework d'origine. Ce repo n'a
pas cet équivalent : la résolution se fait ici à la volée (remote `git`, `CLAUDE.md` du projet
s'il documente une convention de branches) plutôt que depuis un fichier dédié. Si un projet a une
convention de branches/labels stable et non triviale, envisager de l'écrire dans son `CLAUDE.md`
plutôt que de la faire redéduire à chaque fois.
