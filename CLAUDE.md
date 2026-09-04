# Instructions Claude Code — ai-playbook

Chargé automatiquement par Claude Code en session sur ce repo — symétrique à [`AGENTS.md`](AGENTS.md)
(instructions Codex). Le `README.md` reste le pitch/la référence pour tout lecteur (structure,
inventaire, origine) ; ce fichier est le mode opératoire pour qui travaille effectivement dans ce
repo, humain ou Claude Code.

## Comment utiliser le contenu de ce repo

Rien ici n'est un package à installer — tout se copie-colle et se modifie. Concrètement :

- **`agents/`, `skills/`** : copier le fichier (ou dossier) dans `.claude/agents/` ou
  `.claude/skills/` du projet cible, puis lire le contenu avant de s'en servir. Plusieurs fichiers
  contiennent un bloc `> À adapter par projet...` explicite (ID de ticket, tracker, organisation de
  collection API...) — ce n'est pas une doc à part, c'est la checklist d'adaptation.
- **`prompts/`** : copier-coller le texte dans une conversation, en remplaçant les `<placeholders>`.
- **`rules/`** : pas fait pour être copié tel quel — à piocher pour amorcer ou compléter le
  `CLAUDE.md`/`.cursorrules` d'un projet. Ce qui est spécifique à une stack va dans le repo du
  projet, pas ici.
- **`templates/`** : squelette de fichiers/dossiers à copier tel quel, à remplir ensuite.

## Écrire dans ce repo

**Pas de données réelles d'un projet précis — seulement le concept généralisé.** Pas d'ID de
ticket réel, de nom de client/projet, ni de cas vécu identifiable : illustrer avec un exemple
générique (`<ID>`, "un ticket donné", un cas anonymisé) plutôt qu'un identifiant réel. Un concept
doit rester compréhensible et utile sans connaître le projet d'origine — sinon ça n'a plus rien à
faire ici, ça reste dans le repo du projet concerné.

**Appliqué techniquement, pas seulement suivi "en général"** : un hook `PreToolUse` (voir
[`rules/hooks.md`](rules/hooks.md)) bloque toute écriture (`Write`/`Edit`) contenant un ban word
listé dans `.claude/hooks/banwords.local.txt`, même sur demande explicite pour ce tour — liste
**locale au poste, jamais commitée** (elle peut contenir de vrais noms de client/projet, `.gitignore`),
à créer/compléter soi-même à chaque fois qu'un tel terme se glisse dans du contenu généralisé pour ce
repo. Sans ce fichier (ex. clone frais), le hook ne bloque rien — juste une note en sortie.
Nécessite d'avoir ouvert `/hooks` une fois (ou redémarré la session) après la création de
`.claude/settings.json` pour que Claude Code recharge la config.

## Comment ce repo lui-même est versionné

Adopte son propre modèle documenté en interne : [Git Flow](rules/git-flow.md) — branches
permanentes `main`/`develop`, branches temporaires `feature/*`/`release/*`/`hotfix/*` (skill
[`git-flow`](skills/git-flow/SKILL.md), vérification avant fusion via l'agent
[`git-flow-reviewer`](agents/git-flow-reviewer.md)). `develop` est la branche de travail par
défaut pour toute contribution à ce repo — brancher `feature/*` depuis `develop`, jamais depuis
`main` directement. Le défaut GitHub du repo est aligné sur `develop`.

## Workflow actuel : traiter un ticket de bout en bout

1. **Étude d'architecture en amont, conseillée avant d'ouvrir le ticket** — pour un sujet non
   trivial, poser le design/la faisabilité avant d'entrer dans `start-ticket`. Fait aujourd'hui via
   un prompt ad hoc, pas encore via un skill dédié dans ce repo — à évaluer :
   `aidd-pm/05-spike` sur [`ai-driven-dev/framework`](https://github.com/ai-driven-dev/framework)
   (spike borné par la preuve, pour une incertitude qui bloque l'estimation/la faisabilité/le
   design) semble le candidat le plus proche, pas encore testé.
2. **Identifier le ticket** — clé Jira citée (`<PREFIX>-<NUM>`). `jira-connect` existe mais
   n'est pas authentifié sur ce repo (pas de PAT configuré) : en pratique le contenu est souvent
   **reconstruit depuis le code déjà écrit et les docs de décision existantes** plutôt que récupéré
   en direct — reconstruction signalée explicitement en tête de l'`analyse.md`, avec la mention
   "à recouper avec le ticket réel dès qu'accessible".
3. **`meta/tickets/<ID>/analyse.md` puis `plan.md`** via `start-ticket`. **Statut** en tête de
   `plan.md`, jamais pris pour argent comptant : avant de reprendre un ticket, vérifier dans le
   code/git ce que le plan prétend avoir livré — un statut "en implémentation" peut décrire du
   travail qui n'existe plus (voir point 5).
4. **Implémentation dans l'arbre de travail, jamais committée par Claude** — plus strict que la
   règle générale "pas de commit sans demande explicite pour ce tour"
   ([`rules/general-coding.md`](rules/general-coding.md)) : sur ce repo, `.claude/settings.local.json`
   n'accorde même pas la permission `git commit`/`git push`/`gh` — seules les commandes de lecture
   (`status`/`diff`/`log`/`branch`/`show`) le sont. C'est moi qui committe systématiquement, à la
   fin, moi-même.
5. **Pourquoi cette règle est stricte** — un vécu concret, pas une précaution abstraite : sur un
   ticket récent, du code (DTO, mapper, tests) a été conçu et discuté en session, jamais committé,
   et perdu à la session suivante — la PR réellement mergée sous ce même nom de branche concernait
   un tout autre sujet. `plan.md` documente maintenant ce genre d'écart explicitement ("le code
   décrit n'existe pas dans le code actuel — vérifié le ...") plutôt que de laisser un statut
   trompeur en place.
6. **Décisions d'architecture** proposées à l'étape plan, écrites dans `meta/docs/decisions/` une fois
   validées (voir [`rules/docs-structure.md`](rules/docs-structure.md)) — parfois plusieurs
   documents liés à un même ticket (ex. stratégie initiale, validation architecte, brief transverse
   pour un chantier conséquent).
7. **Commit + PR, une fois que je committe** — message `type(<PREFIX>-<NUM>): résumé` (voir
   `writing-good-commits`), branche `type/<PREFIX>-<NUM>`. Le préfixe de branche n'est pas toujours
   cohérent dans l'historique réel (`fix/`, `feat/`, `feature/` coexistent) — une convention
   déclarée n'est pas toujours une convention respectée, à garder en tête plutôt qu'à corriger
   après coup. PR ouverte et mergée sur GitHub.

`writing-good-pull-requests` et `user-stories` (ajoutés cette session) ne sont pas encore éprouvés
sur ce flux réel — statut "à valider sur un vrai ticket", pas encore "adopté" comme le reste.
