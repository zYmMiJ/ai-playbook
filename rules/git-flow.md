# Git Flow

Modèle de branches (voir [`nvie/gitflow`](https://github.com/nvie/gitflow)) pour un projet avec des
**releases distinctes et versionnées** sur plusieurs environnements (ex. qualif en continu +
demo/prod sur tag). Si le projet n'a qu'un seul environnement en déploiement continu, ce modèle est
probablement inutile — un simple flux à une branche (feature branches courtes + PR vers la branche
par défaut) suffit et évite la charge de maintenir `develop` en plus de `main`.

Documenté ici comme convention à piocher pour un `CLAUDE.md` (voir `README.md` > structure de ce
repo) ; l'exécution concrète (commandes, garde-fous) vit dans le skill
[`git-flow`](../skills/git-flow/SKILL.md), la vérification avant fusion dans l'agent
[`git-flow-reviewer`](../agents/git-flow-reviewer.md).

## Branches permanentes

| Branche | Rôle | Toujours... |
|---|---|---|
| `main` | Code en production. | Déployable. Chaque commit sur `main` correspond à un tag. |
| `develop` | Intégration du travail en cours pour la prochaine release. | À jour de toutes les features acceptées, pas forcément stable/déployable. |

## Branches temporaires

| Type | Part de | Fusionne dans | Nom | Pour |
|---|---|---|---|---|
| `feature/*` | `develop` | `develop` | `feature/<slug>` ou `feature/<ID-ticket>` | Une fonctionnalité, le temps de son développement. |
| `release/*` | `develop` | `main` **et** `develop` | `release/X.Y.Z` | Stabiliser une prochaine version (corrections mineures, bump de version, doc) — pas de nouvelle feature dessus. |
| `hotfix/*` | `main` | `main` **et** `develop` | `hotfix/X.Y.Z` | Corriger la prod sans attendre la prochaine release, en incrémentant le patch. |

`support/*` existe dans le modèle d'origine (maintenance d'une ancienne version majeure en
parallèle) mais reste rare en pratique — hors périmètre ici, à documenter séparément le jour où un
projet en a réellement besoin plutôt que d'anticiper dans le vide.

## Règles de fusion

- **Jamais de fusion directe `feature/* → main`** — toujours via `develop`.
- **`release/*` et `hotfix/*` fusionnent dans les deux branches permanentes**, jamais une seule.
  L'oubli du retour vers `develop` est l'erreur la plus fréquente de ce modèle : `develop` dérive
  silencieusement de `main` (un correctif de hotfix disparaît à la prochaine release construite
  depuis `develop`) sans qu'aucune erreur ne le signale sur le moment.
- **Un hotfix pendant une release en cours** : si `release/*` est déjà ouverte quand un `hotfix/*`
  est fusionné, le correctif doit aussi atteindre la branche `release/*` (rebase/merge de `main`
  dedans) avant que la release ne soit finalisée — sinon la release livrée régresse le correctif.
  Cas limite à signaler explicitement à l'utilisateur, jamais à trancher seul.
- **Seul `main` est taggé.** Un tag correspond toujours à un commit de fusion d'un `release/*` ou
  d'un `hotfix/*`, jamais à un commit isolé.

## Tag et notes de release

Le mécanisme de tag (calcul du numéro, garde-fous, interdiction pour Claude de taguer/pousser
lui-même) est déjà couvert par le skill [`release`](../skills/release/SKILL.md) — pas dupliqué ici.
Une nuance entre les deux contextes où ce skill s'applique :

- **Sans Git Flow** (son cas d'origine) : le numéro de version se lit sur `main` avec un suffixe de
  pré-release à retirer (`X.Y.Z-rc.N` → `X.Y.Z`), parce que `main` avance en continu entre deux
  releases.
- **Avec Git Flow** : le numéro est déjà figé **avant** le tag, au moment où `release/*` ou
  `hotfix/*` est créée (voir skill `git-flow`, actions `release`/`hotfix`) — l'étape "déterminer le
  tag" du skill `release` ne s'applique pas, le reste (garde-fous, interdiction de taguer/pousser
  soi-même) si.

Les notes de release (skill [`generate-release-note`](../skills/generate-release-note/SKILL.md))
s'appliquent normalement une fois le tag pushé et la release validée, sans changement.

## Lien avec un tracker GitHub Issues (kanban, mots-clés de fermeture)

Si les tickets suivis sont des issues GitHub (ex. via un projet Projects v2), les workflows natifs
de ce projet (icône ⚙️ *Workflows*, dans l'UI — pas configurable par API) peuvent déplacer une
carte automatiquement sur *Item added to project* et *Item closed*, sans script ni Action. Un piège
propre à Git Flow avec ce mécanisme : GitHub n'auto-ferme une issue via un mot-clé (`Closes #N`,
`Fixes #N`...) dans une PR **que si cette PR est mergée dans la branche par défaut du repo**. Si
`develop` est la branche par défaut (voir ci-dessus), un mot-clé de fermeture dans une PR
`feature/* → develop` fermerait l'issue — et donc ferait passer sa carte à *Terminé* — dès
l'intégration à `develop`, avant même que le travail soit livré en prod.

- **PR `feature/* → develop`** : référencer l'issue sans mot-clé de fermeture (`Refs #N`,
  `Part of #N`) — elle reste ouverte, la carte reste sur sa colonne intermédiaire.
- **PR `release/*`/`hotfix/* → main`** : là, mot-clé de fermeture (`Closes #N`) — c'est la mise en
  prod réelle, l'issue doit se fermer à ce moment-là.

## Erreurs fréquentes à surveiller

- `release/*` créée depuis `main` au lieu de `develop` (embarque moins que prévu, ou un historique
  incohérent si `main` et `develop` ont divergé).
- `hotfix/*` créée depuis `develop` au lieu de `main` (embarque du travail en cours non encore
  releasé dans un correctif censé être minimal).
- Fusion `release/*`/`hotfix/*` faite dans `main` mais oubliée dans `develop` (voir ci-dessus).
- Nouvelle feature glissée dans une branche `release/*` déjà ouverte (elle doit rester limitée aux
  corrections et à la doc — une vraie feature repart sur son propre `feature/*` pour la release
  suivante).

## À adapter par projet

- Nom exact des branches permanentes (`main`/`master`, `develop`/`dev`) — vérifier l'existant plutôt
  que de supposer.
- Granularité de version pour un hotfix (incrément de patch strict vs cas par cas).
- Fusion par merge commit (préserve l'historique de la branche) vs squash (historique linéaire) —
  suivre la convention déjà en usage sur le repo, ne pas en imposer une nouvelle au passage.
