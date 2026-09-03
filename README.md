# ai-playbook

Mes pratiques de dev avec l'IA (Claude Code), indépendantes d'un projet précis — à copier/adapter
dans n'importe quel repo. Prenez ce qui vous sert, ignorez le reste, adaptez sans demander la
permission.

## Structure

```
ai-playbook/
├── agents/      # agents Claude Code — copier le fichier dans .claude/agents/ d'un projet
├── skills/      # skills Claude Code — copier le dossier dans .claude/skills/ d'un projet
├── prompts/     # prompts type, à copier-coller
├── rules/       # conventions générales, à piocher pour amorcer un CLAUDE.md
└── templates/   # squelettes de fichiers/dossiers à copier tels quels
```

## Comment utiliser ce repo

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
3. **`tickets/<ID>/analyse.md` puis `plan.md`** via `start-ticket`. **Statut** en tête de
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
6. **Décisions d'architecture** proposées à l'étape plan, écrites dans `docs/decisions/` une fois
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

## Inventaire

| Skills | Ce que ça fait | Source |
|---|---|---|
| [`start-ticket`](skills/start-ticket/SKILL.md) | Traite un ticket de bout en bout : analyse → plan → validation → implémentation → doc/commit. | custom |
| [`jira-connect`](skills/jira-connect/SKILL.md) | Connexion à un Jira auto-hébergé (PAT ou cookie de session) pour récupérer un ticket par sa clé. Spécifique à une infra donnée — à adapter/remplacer pour un autre tracker. | custom |
| [`update-api-collections`](skills/update-api-collections/SKILL.md) | Resynchronise les collections Bruno/Postman avec le spec OpenAPI actuel d'un backend Spring Boot/JHipster, sans écraser ce qui a été personnalisé à la main. | custom |
| [`writing-good-commits`](skills/writing-good-commits/SKILL.md) | Rédige un message de commit à partir du diff stagé, aligné sur la convention déjà en usage dans le repo. | custom |
| [`writing-good-pull-requests`](skills/writing-good-pull-requests/SKILL.md) | Rédige et ouvre une PR/MR en brouillon depuis la branche courante (titre/corps depuis le diff, jamais de commit/push/merge). Complète `writing-good-commits`. | adapté de [`ai-driven-dev/framework`](https://github.com/ai-driven-dev/framework) (`plugins/aidd-vcs/skills/02-pull-request`) |
| [`user-stories`](skills/user-stories/SKILL.md) | Produit/affine des User Stories scrum (cadrer → découper → rédiger → évaluer → estimer → ordonner → finaliser), gabarit As/I want/So that + critères d'acceptation, statuts `proposed`/`ready`/`in-progress`/`done`/`cancelled`. | adapté de [`ai-driven-dev/framework`](https://github.com/ai-driven-dev/framework) (`plugins/aidd-pm/skills/02-user-stories`) |
| [`release`](skills/release/SKILL.md) | Donne les commandes pour sortir une release via tag Git (calcul du tag, garde-fous) — ne les exécute jamais soi-même. | généralisé à partir d'un projet Spring Boot réel |
| [`generate-release-note`](skills/generate-release-note/SKILL.md) | Génère les notes de release entre deux tags, groupées par type conventionnel, dans un fichier local — après validation de la release, jamais avant. Complète `release`. | généralisé à partir d'un projet Spring Boot réel |
| [`git-flow`](skills/git-flow/SKILL.md) | Commandes pour créer/terminer une branche feature/release/hotfix selon Git Flow (branches `main`/`develop`) — s'articule avec `release`/`generate-release-note` pour le tag et les notes. | custom |

| Agents | Ce que ça fait | Source |
|---|---|---|
| [`security-reviewer`](agents/security-reviewer.md) | Gabarit de revue de sécurité *spécifique au projet* (fichiers/classes/conventions réels) — complète un skill/agent générique de sécurité, ne le remplace pas. | custom |
| [`api-contract-reviewer`](agents/api-contract-reviewer.md) | Gabarit de revue comparant un type front à son DTO/controller backend, pour détecter un contrat API qui a dérivé (champ renommé/ajouté/supprimé, nullabilité). N'a de sens que sans client API généré. | custom — un seul projet source |
| [`git-flow-reviewer`](agents/git-flow-reviewer.md) | Générique (pas un gabarit à remplir) : vérifie qu'une branche/PR respecte Git Flow (base, cible de fusion, double fusion main+develop) avant de la merger. | custom |

| Rules | Ce que ça fait | Source |
|---|---|---|
| [`general-coding.md`](rules/general-coding.md) | Style, gestion du scope, revue — principes indépendants d'une stack. | custom |
| [`css-units.md`](rules/css-units.md) | Unités CSS/SCSS (`rem`/`px`/`%`/`fr`/`vh`-`vw`/`em`/variables) : à quoi chacune est relative et quand l'utiliser. | custom |
| [`docs-structure.md`](rules/docs-structure.md) | Convention `docs/` (architecture/decisions/modules) et qui la remplit, éprouvée sur deux projets réels. | custom |
| [`hooks.md`](rules/hooks.md) | Ce qu'un hook `settings.json` apporte par rapport à un `CLAUDE.md`, avec un gabarit de contrôle rapide après édition. | custom — `.claude/hooks/README.md` |
| [`mcp.md`](rules/mcp.md) | Ce que MCP apporterait, avec un gabarit de branchement — documenté, pas activé par défaut. | custom — `.claude/mcp/README.md` |
| [`git-flow.md`](rules/git-flow.md) | Modèle de branches main/develop/feature/release/hotfix, quand l'adopter, règles de fusion, erreurs fréquentes. | custom |
| [`context-efficiency.md`](rules/context-efficiency.md) | Limiter la consommation de tokens d'une session : lecture ciblée, sous-agents à bon escient, sortie concise. | custom |

| Prompts | Ce que ça fait | Source |
|---|---|---|
| [`refactor-review.md`](prompts/refactor-review.md) | Force un plan vérifiable (fichiers impactés, critère de succès) avant de lancer un refactor multi-fichiers. | custom (sections "Refactors non triviaux" des `CLAUDE.md`) |

## Origine

Généralisé à partir de deux projets réels (un front Angular, un back Spring Boot), en retirant ce
qui était trop spécifique à l'un ou l'autre. Certains fichiers restent volontairement liés à une
infra précise (ex. `jira-connect` à un Jira auto-hébergé donné) plutôt que génériques à outrance —
un gabarit trop abstrait perd l'essentiel : le detail concret qui évite l'erreur.

## Statut

Alimenté au fil de l'eau, à chaque fois qu'une pratique se répète sur un vrai projet. Pas de
garantie de stabilité tant qu'un skill/agent n'a pas été éprouvé au moins une fois en conditions
réelles.
