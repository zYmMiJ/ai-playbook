---
name: writing-good-commits
description: >
  Rédige un message de commit à partir du diff stagé/à committer. Se déclenche quand l'utilisateur
  demande "écris/propose un message de commit", "commit ça", ou juste avant un `git commit` quand
  aucun message n'a été fourni.
---

# Writing good commits

## Démarche

1. `git diff --staged` (ou `git diff` si rien n'est stagé) — ne jamais deviner le contenu du diff.
2. `git log --oneline -10` pour repérer la convention déjà en usage sur ce repo (Conventional
   Commits type `feat(scope): ...`, préfixe ticket type `RUE-316: ...`, etc.) — s'aligner dessus
   plutôt qu'imposer un format générique.
3. Résumer **le pourquoi**, pas seulement le quoi : le diff montre déjà ce qui a changé, le message
   doit apporter le contexte qui n'est pas dans le code (raison du choix, ticket lié, effet de bord
   corrigé).

## Format par défaut (à défaut de convention détectée)

```
<type>(<scope>): <résumé impératif, minuscule, pas de point final>

<corps optionnel : pourquoi, pas quoi — seulement si le résumé ne suffit pas>
```

Types usuels : `feat`, `fix`, `refactor`, `test`, `docs`, `build`, `chore`.

## Règles

- Résumé ≤ 72 caractères, à l'impératif ("ajoute", pas "ajouté" ni "ajoute des").
- Un commit = un changement logique. Si le diff mélange plusieurs sujets sans rapport, le signaler
  plutôt que d'écrire un message qui les recolle artificiellement.
- Ne jamais committer soi-même sauf demande explicite de l'utilisateur pour ce tour — proposer le
  message, pas l'exécuter.
- Ne pas inventer de ticket/scope non présent dans le diff ou l'historique récent.
