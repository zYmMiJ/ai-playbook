# Structure `docs/` + workflow tickets

Convention éprouvée sur plusieurs projets réels (fronts Angular, backs Spring Boot) : la doc vit en
dehors du code, organisée par intention de lecture plutôt que par date, et se remplit au fil des
tickets plutôt qu'en un bloc dédié à part.

## `docs/` — 3 dossiers de base

- **`architecture/overview.md`** — vue d'ensemble, un seul fichier de départ, à mettre à jour
  plutôt qu'à dupliquer.
- **`decisions/`** — un doc par question technique rattachée à un ticket précis (périmètre,
  impacts, proposition), statut en tête de fichier (`à valider` → `validé`). Pas un journal de
  décisions déjà actées, pas des ADR au sens strict : un document peut rester en attente un moment.
  Index dans `decisions/README.md` (table Document/Ticket/Sujet). Variante ADR numérotée
  ci-dessous quand les décisions ne sont pas rattachées à des tickets.
- **`modules/`** — une fiche par module/écran/composant partagé, seulement pour un piège ou une
  règle qui ne mérite ni l'overview (trop transverse) ni une décision (pas rattaché à un ticket
  précis, ou plus un rappel permanent qu'une décision).

Ajouter d'autres dossiers seulement par besoin réel constaté, pas par symétrie avec un autre projet
(ex. `domain/` pour un modèle de données propre, `gouvernance/` pour du contexte organisationnel —
les deux n'ont de sens que si le projet en a effectivement besoin, pas par défaut).

**Convention de lien** : tous les liens internes sont relatifs à l'emplacement du fichier qui les
contient, pas à `docs/`. Un fichier déplacé doit mettre à jour les liens qui pointent vers lui *et*
ceux qu'il contient.

## Variante : décisions numérotées (ADR)

Pour un projet dont les décisions structurantes ne naissent pas d'un ticket (produit en
construction, pas de tracker, une personne qui décide) — éprouvée sur un back et un front d'un même
produit, plus de 20 décisions chacun :

- Un fichier par décision : `NNNN-titre-court.md` (`0001-…`, `0002-…`). Un numéro n'est **jamais
  réattribué**, même si la décision est abandonnée.
- Statut : `Proposé`, `Acté`, ou `Remplacé par NNNN`.
- Une décision actée **n'est pas réécrite** : on en ajoute une nouvelle qui la remplace, et on met à
  jour le statut de l'ancienne (éventuellement partiellement : `point 1 remplacé par NNNN`).
- Quelques lignes par rubrique suffisent (Contexte / Décision / Conséquences, inconvénients
  acceptés compris). Ne consigner que ce qui est difficile à déduire du code.
- Index dans `decisions/README.md` (Note / Sujet / Statut / **Ferme**) : la colonne "Ferme" relie
  la décision aux questions ouvertes de l'overview qu'elle tranche (`O5`, `O17`…) — l'overview
  garde la liste des questions ouvertes, une question fermée reçoit sa note.
- Le code et les commits citent la décision par son numéro (`refactor: … (décision NNNN)`) — le
  pourquoi d'un changement structurant se retrouve depuis `git log`.

Gabarit : [`../templates/docs/decisions/README-adr.md`](../templates/docs/decisions/README-adr.md).

## Règles d'architecture : vérifiées, pas seulement écrites

Une règle de dépendance documentée (couches, features qui ne se voient qu'à travers leurs services,
pas de cycle) dérive dès qu'elle n'est que dans la doc. La faire vérifier par un test qui échoue au
build (ex. ArchUnit côté JVM, `dependency-cruiser`/règles ESLint côté TS) et citer ce test dans
`docs/architecture/` et le `CLAUDE.md` — la doc explique la règle, le test la garantit.

Compléter par une liste **"choix assumés, à ne pas introduire sans besoin démontré"** (ex.
microservices, CQRS, event sourcing, bus de commandes, `BaseService` générique, interface
systématique par classe) : sans elle, une session propose volontiers une abstraction "propre" que
le projet a déjà écartée.

## Qui remplit cette doc

Le skill [`start-ticket`](../skills/start-ticket/SKILL.md) : à l'étape "plan", chaque décision
d'architecture/design prise pendant l'analyse est **proposée** (pas écrite) pour l'un de ces trois
emplacements, validée par l'utilisateur avec le reste du plan, puis réellement écrite seulement
après implémentation validée. La doc ne dérive donc jamais loin du code — elle avance au même
rythme que les tickets, pas en session de rattrapage à part.

## Gabarits

Squelette copiable dans [`../templates/docs/`](../templates/docs/).
