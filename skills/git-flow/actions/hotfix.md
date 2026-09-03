# Hotfix

## Démarrer

```bash
git checkout main && git pull
git checkout -b hotfix/X.Y.Z
```

**Part de `main`, pas de `develop`** — c'est la différence clé avec `release/*`. `X.Y.Z` = version
courante de `main` avec le patch incrémenté (correction urgente, pas de nouvelle fonctionnalité).

Si une branche `release/*` est déjà ouverte en parallèle : le signaler à l'utilisateur avant de
continuer — le correctif devra aussi atteindre cette branche (voir "Terminer" ci-dessous), pas
seulement `main`/`develop`.

Création de la branche = action locale réversible, exécutable directement sur demande de
l'utilisateur, même règle que pour `feature`/`release`.

## Terminer

Mêmes étapes que pour une release, **dans le même ordre**, aucune omise :

1. **Fusionner `hotfix/X.Y.Z` → `main`** — proposer, jamais exécuter soi-même sans demande
   explicite pour ce tour.
2. **Tag + push sur `main`** — voir le skill [`release`](../../release/SKILL.md), à partir de son
   étape 1 (version déjà fixée au démarrage). Interdiction absolue : jamais exécuté par Claude
   lui-même.
3. **Fusionner `hotfix/X.Y.Z` → `develop`** (retour) — à rappeler activement, même sans demande.
4. **Si une `release/*` est ouverte en parallèle** (signalé au démarrage) : fusionner aussi le
   correctif dedans (`main` dans `release/*`, ou cherry-pick selon la convention du projet) —
   sinon la prochaine release livrée régresse silencieusement le correctif.

Une fois les fusions faites, la branche `hotfix/X.Y.Z` peut être supprimée.

Notes de release : une fois le tag validé en environnement, voir
[`generate-release-note`](../../generate-release-note/SKILL.md) — un hotfix mérite une entrée au
même titre qu'une release normale, ne pas l'omettre parce que c'est "juste un correctif".
