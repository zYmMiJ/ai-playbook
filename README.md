# ai-playbook

Mes pratiques de dev avec l'IA (Claude Code), indépendantes d'un projet précis — à copier/adapter
dans n'importe quel repo. Prenez ce qui vous sert, ignorez le reste, adaptez sans demander la
permission.

Je fais des tests sur ce repo (branche `develop`) — pour une version propre, se référer à la
branche `main`.

## Structure

```
ai-playbook/
├── agents/          # contenu à copier — agents Claude Code (.claude/agents/ d'un projet)
├── prompts/         # contenu à copier — prompts type, à copier-coller
├── rules/           # contenu à copier — conventions générales, à piocher pour un CLAUDE.md
├── skills/          # contenu à copier — skills Claude Code (.claude/skills/ d'un projet)
├── templates/       # contenu à copier — squelettes de fichiers/dossiers à copier tels quels
├── meta/            # fonctionnement interne de ce repo — jamais à copier
│   ├── automation/  #   Codex, CI uniquement — voir AGENTS.md
│   ├── docs/        #   releases/décisions propres à ce repo
│   └── tickets/     #   dogfooding start-ticket (Claude Code)
├── .github/         # workflows CI — Codex (chemin imposé par GitHub Actions)
├── .claude/         # hooks/config — Claude Code (chemin imposé par l'outil)
└── AGENTS.md        # instructions Codex (chemin imposé par l'outil)
```

## Comment utiliser ce repo

Rien ici n'est un package à installer — tout se copie-colle et se modifie : `agents/`/`skills/`
dans `.claude/` d'un projet cible, `prompts/` en copier-coller dans une conversation, `rules/` à
piocher pour amorcer un `CLAUDE.md`, `templates/` à copier tel quel. Détail par dossier (checklist
d'adaptation, exemples) : [`CLAUDE.md`](CLAUDE.md).

## AI tools

### Claude Code

Assistant de développement interactif principal sur ce repo. Utilisé pour :

- l'analyse et l'architecture ;
- l'implémentation ;
- le debugging ;
- les tests ;
- le refactoring.

Voir [`CLAUDE.md`](CLAUDE.md) pour le mode opératoire complet (workflow de ticket, versioning,
règles d'écriture).

### OpenAI Codex

Moteur d'automatisation, réservé à un usage **uniquement** depuis GitHub Actions — jamais en
session interactive. Ne remplace pas Claude Code et ne doit pas devenir un second assistant de
développement général sur ce repo (voir [`AGENTS.md`](AGENTS.md), qui détaille ses
responsabilités actuelles).

Aucun workflow actif ne l'utilise aujourd'hui — plomberie (clé API, secret GitHub) prête pour une
future automatisation, setup et bonnes pratiques de sécurité dans
[`meta/automation/README.md`](meta/automation/README.md).

## Inventaire

| Skills | Ce que ça fait | IA | Source |
|---|---|---|---|
| [`start-ticket`](skills/start-ticket/SKILL.md) | Traite un ticket de bout en bout : analyse → plan → validation → implémentation → doc/commit. | Claude Code | custom |
| [`jira-connect`](skills/jira-connect/SKILL.md) | Connexion à un Jira auto-hébergé (Data Center/Server, PAT ou cookie de session) pour récupérer un ticket par sa clé. Hôte `<jira-host>` à renseigner ; à remplacer pour un autre tracker. | Claude Code | custom |
| [`update-api-collections`](skills/update-api-collections/SKILL.md) | Resynchronise les collections Bruno/Postman avec le spec OpenAPI actuel d'un backend Spring Boot/JHipster, sans écraser ce qui a été personnalisé à la main. Variante "liste de cas de test comme référence" (Bruno complet, Postman adapté). | Claude Code | custom |
| [`writing-good-commits`](skills/writing-good-commits/SKILL.md) | Rédige un message de commit à partir du diff stagé, aligné sur la convention déjà en usage dans le repo. | Claude Code | custom |
| [`writing-good-pull-requests`](skills/writing-good-pull-requests/SKILL.md) | Rédige et ouvre une PR/MR en brouillon depuis la branche courante (titre/corps depuis le diff, jamais de commit/push/merge). Complète `writing-good-commits`. | Claude Code | adapté de [`ai-driven-dev/framework`](https://github.com/ai-driven-dev/framework) (`plugins/aidd-vcs/skills/02-pull-request`) |
| [`user-stories`](skills/user-stories/SKILL.md) | Produit/affine des User Stories scrum (cadrer → découper → rédiger → évaluer → estimer → ordonner → finaliser), gabarit As/I want/So that + critères d'acceptation, statuts `proposed`/`ready`/`in-progress`/`done`/`cancelled`. | Claude Code | adapté de [`ai-driven-dev/framework`](https://github.com/ai-driven-dev/framework) (`plugins/aidd-pm/skills/02-user-stories`) |
| [`release`](skills/release/SKILL.md) | Donne les commandes pour sortir une release via tag Git (calcul du tag, garde-fous) — ne les exécute jamais soi-même. | Claude Code | généralisé à partir d'un projet Spring Boot réel |
| [`generate-release-note`](skills/generate-release-note/SKILL.md) | Génère les notes de release entre deux tags, groupées par type conventionnel, dans un fichier local — après validation de la release, jamais avant. Complète `release`. | Claude Code | généralisé à partir d'un projet Spring Boot réel |
| [`git-flow`](skills/git-flow/SKILL.md) | Commandes pour créer/terminer une branche feature/release/hotfix selon Git Flow (branches `main`/`develop`) — s'articule avec `release`/`generate-release-note` pour le tag et les notes. | Claude Code | custom |

| Agents | Ce que ça fait | IA | Source |
|---|---|---|---|
| [`security-reviewer`](agents/security-reviewer.md) | Gabarit de revue de sécurité *spécifique au projet* (fichiers/classes/conventions réels) — complète un skill/agent générique de sécurité, ne le remplace pas. | Claude Code | custom |
| [`api-contract-reviewer`](agents/api-contract-reviewer.md) | Gabarit de revue comparant un type front à son DTO/controller backend, pour détecter un contrat API qui a dérivé (champ renommé/ajouté/supprimé, nullabilité). N'a de sens que sans client API généré. | Claude Code | custom — un seul projet source |
| [`local-changes-reviewer`](agents/local-changes-reviewer.md) | Gabarit de revue qualité limitée au diff local (working tree + commits de branche non mergés) : idiomes, conventions du repo, tests, migrations. Complète `security-reviewer`. | Claude Code | généralisé à partir d'un reviewer Kotlin/Spring Boot réel |
| [`database-analyst`](agents/database-analyst.md) | Gabarit d'analyse d'une base (souvent legacy) en `permissionMode: plan` : propose requêtes SQL et plan de rapport, agrégats uniquement. | Claude Code | généralisé à partir d'un projet réel — voir `data-governance.md` |
| [`git-flow-reviewer`](agents/git-flow-reviewer.md) | Générique (pas un gabarit à remplir) : vérifie qu'une branche/PR respecte Git Flow (base, cible de fusion, double fusion main+develop) avant de la merger. | Claude Code | custom |
| [`plan-compliance-reviewer`](agents/plan-compliance-reviewer.md) | Générique : compare un diff à son `plan.md`/`SPEC.md` et ne remonte que les écarts de correction ou d'exigences (exigence absente, cas limite non testé, dérive de scope), jamais le style. | Claude Code | custom — doc officielle Claude Code ([ticket 30](meta/tickets/30/)) |

| Rules | Ce que ça fait | IA | Source |
|---|---|---|---|
| [`general-coding.md`](rules/general-coding.md) | Style, gestion du scope, revue — principes indépendants d'une stack. | Claude Code | custom |
| [`css-units.md`](rules/css-units.md) | Unités CSS/SCSS (`rem`/`px`/`%`/`fr`/`vh`-`vw`/`em`/variables) : à quoi chacune est relative et quand l'utiliser. | Claude Code | custom |
| [`docs-structure.md`](rules/docs-structure.md) | Convention `docs/` (architecture/decisions/modules) et qui la remplit, variante ADR numérotée, règles d'architecture vérifiées par test. | Claude Code | custom |
| [`hooks.md`](rules/hooks.md) | Ce qu'un hook `settings.json` apporte par rapport à un `CLAUDE.md`, avec un gabarit de contrôle rapide après édition. | Claude Code | custom — `.claude/hooks/README.md` |
| [`mcp.md`](rules/mcp.md) | Ce que MCP apporterait, avec un gabarit de branchement — documenté, pas activé par défaut. | Claude Code | custom — `.claude/mcp/README.md` |
| [`git-flow.md`](rules/git-flow.md) | Modèle de branches main/develop/feature/release/hotfix, quand l'adopter, règles de fusion, erreurs fréquentes. | Claude Code | custom |
| [`data-governance.md`](rules/data-governance.md) | Projets avec accès à des données réelles : agrégats par défaut, jamais de valeurs individuelles ni d'artifact qui en contient, outils qui échantillonnent à neutraliser. | Claude Code | custom — retrouvé sur trois projets réels |
| [`agents-md.md`](rules/agents-md.md) | `AGENTS.md` source unique des instructions, `CLAUDE.md` réduit à `@AGENTS.md` + spécifique Claude Code, `.claude/` vide tant qu'aucun besoin réel. | Claude Code | custom — quatre repos d'un même produit |
| [`context-efficiency.md`](rules/context-efficiency.md) | Limiter la consommation de tokens d'une session : lecture ciblée, sous-agents à bon escient, sortie concise. | Claude Code | custom |
| [`verification.md`](rules/verification.md) | Donner à Claude un check pass/fail comme critère de fin : quatre niveaux (consigne, `/goal`, hook `Stop`, relecteur vierge), preuve par la sortie de commande. | Claude Code | custom — doc officielle Claude Code ([ticket 30](meta/tickets/30/)) |
| [`session-management.md`](rules/session-management.md) | Une session par chantier, `/clear`, plan mode, interview → `SPEC.md` → nouvelle session, `/rewind` et checkpoints, `/btw`, compaction. | Claude Code | custom — doc officielle Claude Code ([ticket 30](meta/tickets/30/)) |
| [`permissions.md`](rules/permissions.md) | Modes de permission (auto, dontAsk…), règles allow/ask/deny, règle « jamais » posée en deny rule, sandbox, usage sans surveillance. | Claude Code | custom — doc officielle Claude Code ([ticket 30](meta/tickets/30/)) |
| [`parallel-work.md`](rules/parallel-work.md) | Worktrees, `/batch`, boucle `claude -p` testée sur 2-3 fichiers d'abord, sortie JSON pour la CI, questions avant un run sans surveillance. | Claude Code | custom — doc officielle Claude Code ([ticket 30](meta/tickets/30/)) |

| Prompts | Ce que ça fait | IA | Source |
|---|---|---|---|
| [`refactor-review.md`](prompts/refactor-review.md) | Force un plan vérifiable (fichiers impactés, critère de succès) avant de lancer un refactor multi-fichiers. | Claude Code | custom (sections "Refactors non triviaux" des `CLAUDE.md`) |
| [`architecture-study.md`](prompts/architecture-study.md) | Étude d'architecture d'un repo à partir du code réel (couches, flux critique, dette avec `fichier:ligne`, hors périmètre, journal) avant un ticket non trivial. | Claude Code | généralisé à partir de deux études réelles |
| [`spec-interview.md`](prompts/spec-interview.md) | Interview (`AskUserQuestion`) jusqu'à un `SPEC.md` autonome (fichiers, interfaces, hors périmètre, vérification de bout en bout), implémenté ensuite dans une nouvelle session. | Claude Code | custom — doc officielle Claude Code ([ticket 30](meta/tickets/30/)) |

| Automation | Ce que ça fait | IA | Source |
|---|---|---|---|
| [`release-notes`](meta/automation/release-notes/generate.sh) | Génère un brouillon de release notes en CI à partir de l'historique Git entre deux refs, par un script déterministe — pas d'appel API (workflow [`release-notes.yml`](.github/workflows/release-notes.yml), `workflow_dispatch` uniquement). | Script (ex-Codex) | custom — [issue #15](https://github.com/zYmMiJ/ai-playbook/issues/15) → [issue #20](https://github.com/zYmMiJ/ai-playbook/issues/20) |

## Origine

Généralisé à partir d'une dizaine de projets réels (fronts Angular, backs Spring Boot/Kotlin,
services Python, infra, outils de migration de données), en retirant ce qui était trop spécifique à
l'un ou l'autre. Certains fichiers restent volontairement liés à un type d'infra précis (ex.
`jira-connect` à un Jira auto-hébergé) plutôt que génériques à outrance — un gabarit trop abstrait
perd l'essentiel : le détail concret qui évite l'erreur.

## Statut

Alimenté au fil de l'eau, à chaque fois qu'une pratique se répète sur un vrai projet. Pas de
garantie de stabilité tant qu'un skill/agent n'a pas été éprouvé au moins une fois en conditions
réelles.
