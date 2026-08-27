# Documentation — <nom-du-projet>

## Par où commencer

- Nouveau sur le projet, besoin d'une vue d'ensemble → [`architecture/overview.md`](architecture/overview.md)
- Comprendre pourquoi une décision a été prise sur un chantier en cours → [`decisions/`](decisions/README.md)
- Piège/règle métier propre à un module/écran/composant → [`modules/`](modules/README.md)

## Structure

```
docs/
├── architecture/   Vue d'ensemble du système + concepts transverses
├── decisions/      Études/propositions rattachées à un ticket, avant implémentation
└── modules/        Une fiche par module, pour un piège ou une règle spécifique
```

**Convention de lien** : tous les liens internes sont relatifs, résolus depuis l'emplacement du
fichier qui les contient — pas depuis `docs/`. Un fichier déplacé doit mettre à jour les liens qui
pointent vers lui *et* ceux qu'il contient.

<!-- Voir ../../rules/docs-structure.md pour la logique complète avant de personnaliser. -->
