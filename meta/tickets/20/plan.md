Statut : implémenté

## Objectif de l'US

Remplacer le workflow `codex-release-notes.yml` (appel Codex/OpenAI) par un script déterministe qui
applique les mêmes règles de catégorisation, sans clé API ni coût — voir `analyse.md` pour le
constat (le prompt Codex était déjà 100% déterministe) et les options écartées.

## Challenge de l'architecture (avant implémentation)

- **Sur-architecture ?** Non : 1 script bash, 1 workflow modifié (renommé), pas de nouveau langage
  ni dépendance (pas de Node/Python à installer sur le runner alors que `bash`/`git`/`grep` sont
  déjà là).
- **Duplication avec `generate-release-note` (skill) ?** Duplication de logique assumée, pas de
  fichier partagé : le skill s'exécute en session interactive Claude Code (pas de script à
  invoquer), le workflow tourne sur un runner GitHub Actions isolé. Un script commun serait plus
  élégant mais demanderait de faire dépendre le skill d'un fichier `meta/automation/`, qui n'a de
  sens que pour la CI dans la structure actuelle du repo (voir `CLAUDE.md`, `meta/` = "jamais à
  copier") — pas fait pour ce ticket, à revisiter seulement si la duplication cause un vrai
  problème constaté (les deux logiques divergent, un bug corrigé dans l'un pas dans l'autre).
- **Permissions minimales ?** Inchangé : `permissions: contents: read`, aucun droit d'écriture — un
  script n'a pas besoin de plus que Codex n'en avait.
- **Une étape nécessite-t-elle une écriture sur le repository ?** Non, inchangé : `release-notes.md`
  écrit dans le workspace du runner, publié en artifact, jamais commité/poussé.
- **Le script peut-il diverger du comportement déjà validé (prompt Codex) ?** Risque inverse de
  Codex : pas d'hallucination possible, mais une regex mal écrite pourrait mal classer un commit
  silencieusement. Mitigé par des cas de test manuels explicites (voir Étapes) plutôt qu'une suite
  de tests automatisée dédiée, jugée disproportionnée pour un script d'une cinquantaine de lignes.

## Critères d'acceptation

- [x] Le workflow (`workflow_dispatch`, inputs `from_ref`/`to_ref`) génère `release-notes.md` sans
      appel API.
- [x] Catégories `Fonctionnalités`/`Corrections`/`Documentation`/`Autres`, dans cet ordre, catégorie
      vide omise.
- [x] Breaking change détecté uniquement sur marqueur explicite (`!` ou `BREAKING CHANGE:`), jamais
      inféré.
- [x] Commit non conventionnel listé tel quel sous "Autres".
- [x] Plage vide → message explicite dans le fichier de sortie, pas de fichier vide ni de contenu
      inventé.
- [x] Résultat toujours publié en artifact GitHub Actions, jamais écrit dans `meta/docs/releases/`.
- [x] Aucun secret requis pour ce workflow.
- [x] `AGENTS.md` reflète que Codex n'a plus de responsabilité active (plomberie conservée).
- [x] Documentation (`README.md` racine, `meta/automation/`) cohérente avec le nouveau mécanisme.

## Changements fichier par fichier

- `meta/tickets/20/analyse.md`, `plan.md` — ce ticket.
- `meta/automation/release-notes/generate.sh` — nouveau script (remplace la logique du prompt
  Codex) : prend `FROM_REF`/`TO_REF` en variables d'env ou arguments, parse `git log --no-merges`,
  catégorise, gère plage vide et breaking changes, écrit le Markdown sur stdout.
- `meta/automation/release-notes/prompt.md` — supprimé (règles reprises dans le script).
- `meta/automation/release-notes/README.md` — réécrit : documente le nouveau mécanisme
  (déclenchement, format de sortie, pas de setup requis), plus rien sur la clé API/Codex.
- `meta/automation/README.md` — nouveau : doc générale de setup Codex (créer clé/projet OpenAI,
  secret GitHub, sécurité, rotation) reprise depuis l'ancien
  `meta/automation/release-notes/README.md`, décorrélée d'un cas d'usage précis — pour la prochaine
  automatisation Codex.
- `.github/workflows/codex-release-notes.yml` → `.github/workflows/release-notes.yml` (renommé) :
  même structure (checkout, résolution de plage, contexte Git), l'étape `openai/codex-action@v1`
  remplacée par un appel à `generate.sh`.
- `AGENTS.md` — section "Codex responsibilities" mise à jour : plus d'entrée active, note que la
  plomberie reste en place pour un futur usage.
- `README.md` (racine) — section "OpenAI Codex" mise à jour : ne référence plus release-notes comme
  cas d'usage actuel ; section "Claude Code"/Inventaire si le tableau référence l'ancien chemin.
- `.gitignore` — retire `.codex-prompt.md` (fichier de travail qui n'existe plus, le script ne
  passe plus par un prompt assemblé), garde `release-notes.md`.

## Cas limites

Voir `analyse.md` — repris à l'identique du comportement Codex validé sur #15 (plage vide, commit
non conventionnel, breaking change, `from_ref` manquant).

## Décisions

- **Script bash plutôt que Node/Python** — proposé pour : rester tel quel, cohérent avec le reste du
  workflow (déjà en bash pour la résolution de plage) et évite d'ajouter un runtime supplémentaire
  au job pour ~50 lignes de logique.
- **Duplication assumée avec `generate-release-note` plutôt que fichier partagé** — voir Challenge
  d'architecture ci-dessus ; à revisiter seulement si la duplication cause un écart constaté.
- **Plomberie Codex conservée (`AGENTS.md`, secret, action)** — décision utilisateur explicite en
  session, pas un choix technique de ce ticket ; documentée ici pour que ce ne soit pas pris pour un
  oubli en relisant ce plan plus tard.

## Fichiers prévus

Voir "Changements fichier par fichier" ci-dessus.

## Étapes

1. Créer l'US — [issue #20](https://github.com/zYmMiJ/ai-playbook/issues/20) +
   `meta/tickets/20/analyse.md`/`plan.md` — fait.
2. Écrire `generate.sh` — fait.
3. Renommer/adapter le workflow — fait.
4. Supprimer `prompt.md`, réécrire les deux README (`release-notes/` et nouveau `automation/`) —
   fait.
5. Mettre à jour `AGENTS.md` et `README.md` racine — fait.
6. Tester le script en local sur ce repo (plage `0.1.0..0.2.0`, plage vide, commit non
   conventionnel) — **fait, voir résultat donné à l'utilisateur avec l'implémentation**.
7. Tester le workflow sur GitHub Actions — **fait** : PR #21 mergée sur `develop`, workflow
   déclenché (`from_ref=0.1.0`, `to_ref=HEAD`) — run
   [33864629161](https://github.com/zYmMiJ/ai-playbook/actions/runs/33864629161), succès en 7s,
   sortie catégorisée correctement, aucun secret consommé.

## Definition of Done

- [x] Les fichiers listés existent, le YAML est syntaxiquement valide, le script est exécutable et
      testé en local sur au moins un cas réel de ce repo.
- [x] Plus aucune référence à Codex dans le chemin de génération des release notes (script, workflow,
      doc du dossier `release-notes/`).
- [x] `AGENTS.md`/`README.md` cohérents avec l'état réel (Codex configuré mais sans workflow actif).
- [x] Le workflow renommé a été exécuté au moins une fois avec succès sur GitHub — run
      [33864629161](https://github.com/zYmMiJ/ai-playbook/actions/runs/33864629161), voir étape 7.
