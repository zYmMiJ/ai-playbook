# Feature

## Démarrer

```bash
git checkout develop && git pull
git checkout -b feature/<slug-ou-ID-ticket>
```

Nom de branche : un slug court (`feature/export-csv`) ou l'ID de ticket si le projet en a un
([`start-ticket`](../../start-ticket/SKILL.md) utilise déjà `<PREFIX>-<NUM>`, réutiliser la même
convention plutôt qu'en inventer une seconde).

Création de la branche = action locale réversible, exécutable directement sur demande de
l'utilisateur (pas besoin d'un "go" séparé pour ce geste précis) — contrairement au push.

## Terminer

1. Vérifier que `develop` n'a pas avancé entre-temps :
   ```bash
   git fetch origin
   git log origin/develop..develop --oneline   # develop local est-il à jour ?
   git log develop..feature/<...> --oneline    # ce que la feature apporte réellement
   ```
   Si `develop` a avancé de façon significative, le signaler avant de proposer la PR — un rebase/
   merge de `develop` dans la feature peut être nécessaire selon la convention du projet.
2. Ouvrir la PR **vers `develop`, jamais vers `main`** — voir le skill
   [`writing-good-pull-requests`](../../writing-good-pull-requests/SKILL.md) pour la démarche
   complète (titre/corps depuis le diff, toujours en brouillon, jamais de merge par Claude).
3. Une fois la PR mergée (par l'utilisateur), la branche `feature/*` est généralement supprimée par
   l'outil VCS (option "delete branch on merge") — ne pas la supprimer soi-même en local sans
   confirmation que la PR est bien mergée.
