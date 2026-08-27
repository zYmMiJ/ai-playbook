# Conventions générales

Principes indépendants d'une stack, à piocher pour amorcer le `CLAUDE.md`/`.cursorrules`/etc. d'un
projet. Ce qui est spécifique à un framework va dans le repo du projet, pas ici.

## Style

- Le code généré doit lire comme le code existant autour : même densité de commentaires, mêmes
  conventions de nommage, même idiome. Ne pas imposer un style "par défaut" de l'IA sur un repo qui
  en a déjà un.
- Un commentaire explique le **pourquoi** (contrainte, décision, piège évité), pas le **quoi** —
  le code dit déjà le quoi.

## Changements

- Ne pas élargir le scope d'une demande sans le dire. Une correction ponctuelle reste ponctuelle
  sauf accord explicite pour un refactor plus large.
- Sur un refactor multi-fichiers, poser un critère de succès vérifiable avant d'éditer (voir
  [`../prompts/refactor-review.md`](../prompts/refactor-review.md)).
- Ne jamais committer/pousser sans demande explicite pour ce tour précis — une autorisation donnée
  une fois ne vaut pas pour la suite de la session.

## Revue

- Un `lint` qui passe ne veut pas dire "sans defaut" — vérifier ce que le linter du projet ignore
  explicitement (règles désactivées) avant de s'y fier.
- Un test qui passe ne prouve la correction que de ce qu'il couvre — vérifier la couverture réelle
  avant de présumer qu'un changement est testé.
