Statut : implémenté

## Objectif de l'US

Formaliser dans `CLAUDE.md` ce que `README.md` (racine) peut/ne peut pas contenir, pour arrêter la
dérive narrative constatée sur la section Codex/release-notes (#20) — voir `analyse.md`.

## Challenge de l'architecture (avant implémentation)

- **Sur-architecture ?** Non : une section dans un fichier déjà chargé à chaque session, pas de
  nouveau fichier `rules/` ni de hook (voir Options écartées dans `analyse.md` — pas d'heuristique
  fiable pour détecter du narratif automatiquement).
- **Le correctif dépasse-t-il le README actuel ?** Non : appliqué uniquement aux deux dérives
  repérées sur ce repo (paragraphe narratif Codex, sous-section `Release notes en CI`) — pas de
  réécriture plus large du README au-delà de ces deux points, validée avec l'utilisateur avant
  d'agir (`AskUserQuestion`, deux réponses "recommandé" confirmées).

## Critères d'acceptation

- [x] `CLAUDE.md` formalise explicitement la portée de `README.md` (deux garde-fous : tableau
      Inventaire = seul niveau de détail par item ; jamais de narratif de décision) + un test rapide
      de relecture.
- [x] Le README actuel est corrigé sur les deux dérives repérées (paragraphe narratif Codex/#15/#20
      + sous-section `Release notes en CI` dupliquant le tableau).
- [x] Pas de nouveau hook technique (heuristique de détection de narratif jugée peu fiable, voir
      `analyse.md`).

## Changements fichier par fichier

- `meta/tickets/22/analyse.md`, `plan.md` — ce ticket.
- `CLAUDE.md` — nouvelle section "Ce que `README.md` ne doit pas contenir", juste après l'intro.
- `README.md` — section "OpenAI Codex" allégée (retrait du narratif #15→#20/"jamais eu besoin d'un
  modèle") ; sous-section "Release notes en CI" supprimée (doublon avec le tableau Inventaire +
  `meta/automation/release-notes/README.md`).

## Cas limites

- **La règle elle-même pourrait dériver** (devenir trop longue, elle-même narrative) — pas de garde
  technique prévue au-delà de sa propre concision actuelle ; à surveiller si elle grossit à son
  tour.
- **Un futur ajout légitime au README ressemble à du narratif sans en être** (ex. un avertissement
  factuel sur un piège connu) — le test de relecture ("état actuel" vs "pourquoi on en est arrivé
  là") tranche : un avertissement sur un piège *actuel* reste acceptable, l'historique de comment il
  a été découvert ne l'est pas.

## Décisions

- **Pas de généralisation vers `rules/` pour l'instant** — voir Options dans `analyse.md` : le
  principe est probablement transposable à d'autres projets, mais pas assez éprouvé ici pour être
  détaché du contexte précis de ce repo (tableau Inventaire, `meta/tickets/`). À reconsidérer si la
  règle tient dans la durée sur ce repo.
- **Pas de hook de détection** — un jugement éditorial n'est pas un contrôle mécaniquement
  vérifiable (voir `rules/hooks.md`, portée des hooks) ; règle écrite dans `CLAUDE.md`, appliquée à
  la relecture, cohérent avec le reste du fichier.

## Fichiers prévus

Voir "Changements fichier par fichier" ci-dessus.

## Étapes

1. Créer l'US — [issue #22](https://github.com/zYmMiJ/ai-playbook/issues/22) +
   `meta/tickets/22/analyse.md`/`plan.md` — fait.
2. Corriger les deux dérives dans `README.md` (validées avec l'utilisateur avant d'agir) — fait.
3. Formaliser la règle dans `CLAUDE.md` — fait.

## Definition of Done

- [x] `CLAUDE.md` contient la règle, avec un test de relecture applicable sans jugement d'expert.
- [x] `README.md` ne contient plus les deux dérives repérées.
- [ ] La règle tient dans la durée sur au moins un futur ticket touchant le README — **à vérifier
      dans le temps**, pas mesurable à l'implémentation.
