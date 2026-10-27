# Décisions

> Variante ADR numérotée de [`README.md`](README.md) — garder l'un **ou** l'autre, renommer celui-ci
> en `README.md`. Voir [`rules/docs-structure.md`](../../../rules/docs-structure.md) pour choisir.

Notes courtes pour consigner une décision structurante **au moment où elle est prise** (voir
[`../architecture/overview.md`](../architecture/overview.md)).

Les questions ouvertes de `overview.md` (`O1`, `O2`…) y restent tant qu'elles ne sont pas
tranchées ; une question qui se ferme reçoit ici sa propre note.

## Convention

- Un fichier par décision : `NNNN-titre-court.md` (`0001-…`, `0002-…`). Un numéro n'est jamais
  réattribué.
- Statut : `Proposé`, `Acté`, ou `Remplacé par NNNN`.
- Une décision actée n'est pas réécrite : on en ajoute une nouvelle qui la remplace, et on met à
  jour le statut de l'ancienne.
- Quelques lignes par rubrique suffisent. Ne consigner que ce qui est difficile à déduire du code.

## Modèle

```markdown
# NNNN — Titre

- Statut : Proposé | Acté | Remplacé par NNNN
- Date : AAAA-MM-JJ

## Contexte
Le problème et les contraintes, en quelques lignes.

## Décision
Ce qui est décidé.

## Conséquences
Ce que cela implique, y compris les inconvénients acceptés.
```

## Index

| Note | Sujet | Statut | Ferme |
|---|---|---|---|
| _(aucune)_ | | | |
