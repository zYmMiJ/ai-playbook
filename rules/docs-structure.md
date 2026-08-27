# Structure `docs/` + workflow tickets

Convention éprouvée sur deux projets réels (un front Angular, un back Spring Boot) : la doc vit en
dehors du code, organisée par intention de lecture plutôt que par date, et se remplit au fil des
tickets plutôt qu'en un bloc dédié à part.

## `docs/` — 3 dossiers de base

- **`architecture/overview.md`** — vue d'ensemble, un seul fichier de départ, à mettre à jour
  plutôt qu'à dupliquer.
- **`decisions/`** — un doc par question technique rattachée à un ticket précis (périmètre,
  impacts, proposition), statut en tête de fichier (`à valider` → `validé`). Pas un journal de
  décisions déjà actées, pas des ADR au sens strict : un document peut rester en attente un moment.
  Index dans `decisions/README.md` (table Document/Ticket/Sujet).
- **`modules/`** — une fiche par module/écran/composant partagé, seulement pour un piège ou une
  règle qui ne mérite ni l'overview (trop transverse) ni une décision (pas rattaché à un ticket
  précis, ou plus un rappel permanent qu'une décision).

Ajouter d'autres dossiers seulement par besoin réel constaté, pas par symétrie avec un autre projet
(ex. `domain/` pour un modèle de données propre, `gouvernance/` pour du contexte organisationnel —
les deux n'ont de sens que si le projet en a effectivement besoin, pas par défaut).

**Convention de lien** : tous les liens internes sont relatifs à l'emplacement du fichier qui les
contient, pas à `docs/`. Un fichier déplacé doit mettre à jour les liens qui pointent vers lui *et*
ceux qu'il contient.

## Qui remplit cette doc

Le skill [`start-ticket`](../skills/start-ticket/SKILL.md) : à l'étape "plan", chaque décision
d'architecture/design prise pendant l'analyse est **proposée** (pas écrite) pour l'un de ces trois
emplacements, validée par l'utilisateur avec le reste du plan, puis réellement écrite seulement
après implémentation validée. La doc ne dérive donc jamais loin du code — elle avance au même
rythme que les tickets, pas en session de rattrapage à part.

## Gabarits

Squelette copiable dans [`../templates/docs/`](../templates/docs/).
