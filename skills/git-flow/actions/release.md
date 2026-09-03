# Release

## Démarrer

```bash
git checkout develop && git pull
git checkout -b release/X.Y.Z
```

`X.Y.Z` se détermine ici, **avant** tout tag — à la différence du skill
[`release`](../../release/SKILL.md) seul (sans Git Flow), qui le lit depuis un suffixe de
pré-release sur `main`. Ici : incrément semver (`MINOR`/`MAJOR` selon ce que `develop` contient
depuis le dernier tag) décidé avec l'utilisateur si le changelog ne le rend pas évident — ne pas
deviner seul un `MAJOR` vs `MINOR`.

Sur cette branche : **uniquement** corrections mineures, bump du fichier de version, mise à jour de
doc — pas de nouvelle fonctionnalité (voir [`rules/git-flow.md`](../../../rules/git-flow.md) >
"Erreurs fréquentes"). Une vraie feature repart sur `feature/*` pour la prochaine release.

Création de la branche = action locale réversible, exécutable directement sur demande de
l'utilisateur, même règle que pour `feature`.

## Terminer

Trois étapes, dans cet ordre, **aucune ne doit être oubliée** :

1. **Fusionner `release/X.Y.Z` → `main`** — proposer la fusion (PR ou merge direct selon la
   convention du repo), ne jamais l'exécuter soi-même sans demande explicite pour ce tour.
2. **Tag + push sur `main`** — voir le skill [`release`](../../release/SKILL.md), à partir de son
   étape 1 directement (l'étape 0 "déterminer le tag" ne s'applique pas : `X.Y.Z` est déjà fixé
   depuis le démarrage). Même interdiction absolue : jamais exécuté par Claude lui-même.
3. **Fusionner `release/X.Y.Z` → `develop`** (retour) — à faire **même si l'utilisateur ne le
   redemande pas explicitement**, c'est cette étape qui est le plus souvent oubliée. La rappeler
   activement plutôt que d'attendre qu'on la demande.

Une fois les deux fusions faites, la branche `release/X.Y.Z` peut être supprimée.

Notes de release : une fois le tag validé en environnement, voir
[`generate-release-note`](../../generate-release-note/SKILL.md).
