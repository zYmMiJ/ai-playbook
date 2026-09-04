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

Moteur d'automatisation, utilisé **uniquement** depuis GitHub Actions — jamais en session
interactive. Ne remplace pas Claude Code et ne doit pas devenir un second assistant de
développement général sur ce repo (voir [`AGENTS.md`](AGENTS.md), qui détaille ses
responsabilités actuelles).

Utilisé aujourd'hui pour la génération de brouillons de release notes
([`meta/automation/release-notes/`](meta/automation/release-notes/), workflow
[`codex-release-notes.yml`](.github/workflows/codex-release-notes.yml)) — voir
[issue #15](https://github.com/zYmMiJ/ai-playbook/issues/15) /
[`meta/tickets/15/`](meta/tickets/15/) pour l'US qui a introduit cette intégration. Codex tourne en
lecture seule (`permission-profile: ':read-only'`), ne peut ni pousser ni merger, et n'écrit jamais
directement dans le repo.

Setup complet (clé API OpenAI, secret GitHub, déclenchement du workflow, coûts) :
[`meta/automation/release-notes/README.md`](meta/automation/release-notes/README.md).

## Inventaire

| Skills | Ce que ça fait | IA | Source |
|---|---|---|---|
| [`start-ticket`](skills/start-ticket/SKILL.md) | Traite un ticket de bout en bout : analyse → plan → validation → implémentation → doc/commit. | Claude Code | custom |
| [`jira-connect`](skills/jira-connect/SKILL.md) | Connexion à un Jira auto-hébergé (PAT ou cookie de session) pour récupérer un ticket par sa clé. Spécifique à une infra donnée — à adapter/remplacer pour un autre tracker. | Claude Code | custom |
| [`update-api-collections`](skills/update-api-collections/SKILL.md) | Resynchronise les collections Bruno/Postman avec le spec OpenAPI actuel d'un backend Spring Boot/JHipster, sans écraser ce qui a été personnalisé à la main. | Claude Code | custom |
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
| [`git-flow-reviewer`](agents/git-flow-reviewer.md) | Générique (pas un gabarit à remplir) : vérifie qu'une branche/PR respecte Git Flow (base, cible de fusion, double fusion main+develop) avant de la merger. | Claude Code | custom |

| Rules | Ce que ça fait | IA | Source |
|---|---|---|---|
| [`general-coding.md`](rules/general-coding.md) | Style, gestion du scope, revue — principes indépendants d'une stack. | Claude Code | custom |
| [`css-units.md`](rules/css-units.md) | Unités CSS/SCSS (`rem`/`px`/`%`/`fr`/`vh`-`vw`/`em`/variables) : à quoi chacune est relative et quand l'utiliser. | Claude Code | custom |
| [`docs-structure.md`](rules/docs-structure.md) | Convention `docs/` (architecture/decisions/modules) et qui la remplit, éprouvée sur deux projets réels. | Claude Code | custom |
| [`hooks.md`](rules/hooks.md) | Ce qu'un hook `settings.json` apporte par rapport à un `CLAUDE.md`, avec un gabarit de contrôle rapide après édition. | Claude Code | custom — `.claude/hooks/README.md` |
| [`mcp.md`](rules/mcp.md) | Ce que MCP apporterait, avec un gabarit de branchement — documenté, pas activé par défaut. | Claude Code | custom — `.claude/mcp/README.md` |
| [`git-flow.md`](rules/git-flow.md) | Modèle de branches main/develop/feature/release/hotfix, quand l'adopter, règles de fusion, erreurs fréquentes. | Claude Code | custom |
| [`context-efficiency.md`](rules/context-efficiency.md) | Limiter la consommation de tokens d'une session : lecture ciblée, sous-agents à bon escient, sortie concise. | Claude Code | custom |

| Prompts | Ce que ça fait | IA | Source |
|---|---|---|---|
| [`refactor-review.md`](prompts/refactor-review.md) | Force un plan vérifiable (fichiers impactés, critère de succès) avant de lancer un refactor multi-fichiers. | Claude Code | custom (sections "Refactors non triviaux" des `CLAUDE.md`) |

| Automation | Ce que ça fait | IA | Source |
|---|---|---|---|
| [`release-notes`](meta/automation/release-notes/prompt.md) | Génère un brouillon de release notes en CI à partir de l'historique Git entre deux refs (workflow [`codex-release-notes.yml`](.github/workflows/codex-release-notes.yml), `workflow_dispatch` uniquement, lecture seule). | Codex | custom — [issue #15](https://github.com/zYmMiJ/ai-playbook/issues/15) |

## Origine

Généralisé à partir de deux projets réels (un front Angular, un back Spring Boot), en retirant ce
qui était trop spécifique à l'un ou l'autre. Certains fichiers restent volontairement liés à une
infra précise (ex. `jira-connect` à un Jira auto-hébergé donné) plutôt que génériques à outrance —
un gabarit trop abstrait perd l'essentiel : le detail concret qui évite l'erreur.

## Statut

Alimenté au fil de l'eau, à chaque fois qu'une pratique se répète sur un vrai projet. Pas de
garantie de stabilité tant qu'un skill/agent n'a pas été éprouvé au moins une fois en conditions
réelles.
