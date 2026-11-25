# Gestion de session

Quand ouvrir, vider, revenir en arrière ou reprendre une session Claude Code — indépendant d'une
stack. Le coût en tokens de ces choix est traité dans [`context-efficiency.md`](context-efficiency.md) ;
ici, c'est la qualité : un contexte focalisé sur une seule tâche donne de meilleures réponses.

Commandes et raccourcis vérifiés dans la doc officielle (`best-practices`, `checkpointing`,
`commands`, `cli-reference`, `permission-modes`, `context-window`, `memory`) le 2026-11-26.

## Une session par chantier

- Nommer la session dès qu'un chantier s'étale sur plusieurs jours : `claude -n <nom>` au lancement
  ou `/rename <nom>` en cours de route, puis `claude --resume <nom>` pour la reprendre (checkpoints
  compris). `claude --continue` reprend la plus récente du dossier.
- `/clear` entre deux tâches sans rapport : ça ne coûte rien, et la tâche suivante ne relit pas
  l'historique de la précédente à chaque tour. `/clear <nom>` nomme la session qu'on quitte pour y
  revenir via `/resume`.
- Sur une tâche longue à plusieurs étapes (ex. un ticket : analyse → implémentation → revue), un
  `/clear` entre étapes plutôt qu'une conversation qui accumule les trois. Ce qui doit survivre
  passe par un **artefact écrit** (plan, notes de ticket), pas par l'historique — voir
  [`start-ticket`](../skills/start-ticket/SKILL.md), dont `tickets/<ID>/plan.md` sert de relais.

## Explorer → planifier → coder → committer

- **Plan mode** pour un changement à relire avant qu'il touche le disque : `Shift+Tab` jusqu'à
  `⏸ plan mode on`, ou `claude --permission-mode plan`. Claude lit et propose, n'édite rien avant
  approbation. `Ctrl+G` ouvre le plan proposé dans l'éditeur pour le corriger directement.
  Avec le réglage `showClearContextOnPlanAccept`, l'approbation propose aussi de vider le contexte
  de planification.
- **Sauter le plan** quand le diff se décrit en une phrase (renommage, typo, une ligne de config) :
  le plan coûterait plus que la correction.
- **Grosse fonctionnalité** : faire interviewer par Claude (questions à choix via `AskUserQuestion`)
  jusqu'à pouvoir écrire un `SPEC.md` autonome, puis implémenter **dans une nouvelle session** à
  partir de ce fichier — contexte propre et définition de « fini » écrite. Prompt :
  [`../prompts/spec-interview.md`](../prompts/spec-interview.md).

## Reprendre la main

- `Esc` : arrête Claude en pleine action, garde tout jusque-là — pour réorienter sans perdre le
  travail.
- `/rewind` (ou `Esc` deux fois sur un prompt vide) : menu de retour à un message précédent —
  restaurer code et conversation, la conversation seule, ou le code seul ; ou résumer la
  conversation à partir de / jusqu'à ce message pour libérer de la place. Rend peu risqué l'essai
  d'une approche audacieuse.
- **Les checkpoints ne remplacent pas git** : ils ne suivent que les fichiers édités par les outils
  d'édition de Claude dans la conversation principale. Un fichier modifié seulement par une commande
  Bash (ou par un sous-agent) n'est pas restauré.
- **Après deux corrections ratées sur le même point** : `/clear` et un nouveau prompt qui intègre ce
  qu'on a appris, plutôt qu'une troisième correction — sinon Claude relit à chaque tour deux
  tentatives ratées.
- `/btw <question>` : question annexe dont la réponse n'entre pas dans l'historique.

## Compaction

- La conversation est compactée automatiquement avant que la fenêtre ne soit pleine ;
  `/compact <focus>` (ex. `/compact garde les changements d'API et les commandes de test`) choisit
  ce que le résumé conserve — à lancer avant d'attaquer une longue nouvelle tâche.
- Ce qui survit : le `CLAUDE.md` racine et les rules sans `paths:` sont **relus depuis le disque**,
  le plan écrit en plan mode aussi. Ce qui se perd : une consigne donnée **uniquement en
  conversation**. Une consigne qui doit tenir toute la session va donc dans `CLAUDE.md`, pas dans
  un message. Pour ré-injecter autre chose après compaction : hook `SessionStart` avec le matcher
  `compact` (voir [`hooks.md`](hooks.md)).
