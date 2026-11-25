# ai-playbook

Mes pratiques de dev avec l'IA (Claude Code), indépendantes d'un projet précis — à copier et
adapter dans n'importe quel repo. Prenez ce qui vous sert, ignorez le reste.

Version stable : branche `main` ([notes de release](meta/docs/releases/README.md)). `develop` sert
aux essais.

## Structure

```
ai-playbook/
├── agents/          # à copier — agents Claude Code (.claude/agents/ d'un projet)
├── prompts/         # à copier-coller dans une conversation
├── rules/           # à piocher pour amorcer le CLAUDE.md d'un projet
├── skills/          # à copier — skills Claude Code (.claude/skills/ d'un projet)
├── templates/       # squelettes de fichiers à copier tels quels
├── meta/            # fonctionnement interne de ce repo — jamais à copier
│   ├── automation/  #   scripts CI et setup Codex
│   ├── docs/        #   notes de release
│   └── tickets/     #   analyses et plans des tickets de ce repo
├── .github/         # workflows CI
├── .claude/         # hooks et settings Claude Code de ce repo
└── AGENTS.md        # instructions Codex
```

## Comment utiliser ce repo

Rien ne s'installe : tout se copie puis s'adapte. Plusieurs fichiers contiennent un bloc
`> À adapter par projet` — c'est la checklist d'adaptation. Détail par dossier :
[`CLAUDE.md`](CLAUDE.md).

## AI tools

- **Claude Code** — assistant de développement de ce repo (analyse, implémentation, revue). Mode
  opératoire : [`CLAUDE.md`](CLAUDE.md).
- **OpenAI Codex** — réservé à GitHub Actions, jamais en session interactive. Aucun workflow ne
  l'utilise aujourd'hui ; setup prêt dans [`meta/automation/README.md`](meta/automation/README.md),
  périmètre dans [`AGENTS.md`](AGENTS.md).

## Inventaire

| Skills | Ce que ça fait | Source |
|---|---|---|
| [`start-ticket`](skills/start-ticket/SKILL.md) | Traite un ticket de bout en bout : analyse → plan (avec commande de vérification) → validation → implémentation → revue du diff → commit. | custom |
| [`jira-connect`](skills/jira-connect/SKILL.md) | Récupère un ticket par sa clé sur un Jira auto-hébergé (PAT ou cookie de session). | custom |
| [`update-api-collections`](skills/update-api-collections/SKILL.md) | Resynchronise des collections Bruno/Postman avec le spec OpenAPI d'un backend Spring Boot, sans écraser les personnalisations. | custom |
| [`writing-good-commits`](skills/writing-good-commits/SKILL.md) | Rédige un message de commit à partir du diff, aligné sur la convention du repo. | custom |
| [`writing-good-pull-requests`](skills/writing-good-pull-requests/SKILL.md) | Rédige et ouvre une PR/MR en brouillon depuis la branche courante. | adapté de [`ai-driven-dev/framework`](https://github.com/ai-driven-dev/framework) |
| [`user-stories`](skills/user-stories/SKILL.md) | Produit et affine des User Stories (cadrer → découper → rédiger → évaluer → estimer → ordonner → finaliser). | adapté de [`ai-driven-dev/framework`](https://github.com/ai-driven-dev/framework) |
| [`release`](skills/release/SKILL.md) | Sort une release via tag Git (calcul du tag, garde-fous) ; tague et pousse seulement après permission explicite. | généralisé d'un projet Spring Boot |
| [`generate-release-note`](skills/generate-release-note/SKILL.md) | Génère les notes de release depuis le dernier tag, sur la branche de release, avant le tag. | généralisé d'un projet Spring Boot |
| [`git-flow`](skills/git-flow/SKILL.md) | Crée et termine les branches feature/release/hotfix selon Git Flow (`main`/`develop`). | custom |

| Agents | Ce que ça fait | Source |
|---|---|---|
| [`plan-compliance-reviewer`](agents/plan-compliance-reviewer.md) | Générique : compare un diff à son `plan.md`/`SPEC.md`, ne remonte que les écarts de correction ou d'exigences, jamais le style. | doc officielle Claude Code ([ticket 30](meta/tickets/30/)) |
| [`git-flow-reviewer`](agents/git-flow-reviewer.md) | Générique : vérifie qu'une branche/PR respecte Git Flow (base, cible, double fusion) avant merge. | custom |
| [`local-changes-reviewer`](agents/local-changes-reviewer.md) | Gabarit : revue qualité limitée au diff local (idiomes, conventions du repo, tests, migrations). | généralisé d'un reviewer Kotlin/Spring Boot |
| [`security-reviewer`](agents/security-reviewer.md) | Gabarit : revue de sécurité sur les fichiers et conventions réels du projet. | custom |
| [`api-contract-reviewer`](agents/api-contract-reviewer.md) | Gabarit : détecte un contrat API front/back qui a dérivé, quand il n'y a pas de client généré. | custom |
| [`database-analyst`](agents/database-analyst.md) | Gabarit : analyse d'une base en lecture seule, requêtes et plan de rapport, agrégats uniquement. | généralisé d'un projet réel |

| Rules | Ce que ça fait | Source |
|---|---|---|
| [`general-coding.md`](rules/general-coding.md) | Style, scope, revue — principes indépendants d'une stack. | custom |
| [`verification.md`](rules/verification.md) | Un check pass/fail comme critère de fin : consigne, `/goal`, hook `Stop`, relecteur vierge ; preuve par la sortie. | doc officielle Claude Code ([ticket 30](meta/tickets/30/)) |
| [`session-management.md`](rules/session-management.md) | Une session par chantier, `/clear`, plan mode, `SPEC.md` puis nouvelle session, `/rewind`, compaction. | doc officielle Claude Code ([ticket 30](meta/tickets/30/)) |
| [`context-efficiency.md`](rules/context-efficiency.md) | Contexte focalisé : lecture ciblée, sous-agents selon le volume lu, `CLAUDE.md` minimal, défaillances de contexte. | custom + doc officielle Claude Code |
| [`permissions.md`](rules/permissions.md) | Modes de permission, règles allow/ask/deny, règle « jamais » posée en règle, sandbox, usage sans surveillance. | doc officielle Claude Code ([ticket 30](meta/tickets/30/)) |
| [`parallel-work.md`](rules/parallel-work.md) | Worktrees, `/batch`, boucle `claude -p` testée sur 2-3 fichiers d'abord, sortie JSON pour la CI. | doc officielle Claude Code ([ticket 30](meta/tickets/30/)) |
| [`hooks.md`](rules/hooks.md) | Hook = garanti, `CLAUDE.md` = indicatif ; gabarits de contrôle après édition et de `Stop` bloquant. | custom — hooks en place dans `.claude/` |
| [`mcp.md`](rules/mcp.md) | CLI d'abord, MCP pour un système sans CLI ; gabarit de branchement. | custom |
| [`agents-md.md`](rules/agents-md.md) | `AGENTS.md` source unique des instructions, `CLAUDE.md` réduit à son import. | custom — quatre repos d'un même produit |
| [`docs-structure.md`](rules/docs-structure.md) | Convention `docs/` (architecture/decisions/modules), variante ADR, règles d'architecture testées. | custom |
| [`git-flow.md`](rules/git-flow.md) | Modèle de branches `main`/`develop`/`feature`/`release`/`hotfix`, règles de fusion, erreurs fréquentes. | custom |
| [`data-governance.md`](rules/data-governance.md) | Accès à des données réelles : agrégats par défaut, jamais de valeurs individuelles. | custom — trois projets réels |
| [`css-units.md`](rules/css-units.md) | Unités CSS : à quoi chacune est relative et quand l'utiliser. | custom |

| Prompts | Ce que ça fait | Source |
|---|---|---|
| [`spec-interview.md`](prompts/spec-interview.md) | Interview jusqu'à un `SPEC.md` autonome, implémenté ensuite dans une nouvelle session. | doc officielle Claude Code ([ticket 30](meta/tickets/30/)) |
| [`architecture-study.md`](prompts/architecture-study.md) | Étude d'architecture d'un repo à partir du code réel, avant un ticket non trivial. | généralisé de deux études réelles |
| [`refactor-review.md`](prompts/refactor-review.md) | Force un plan vérifiable avant un refactor multi-fichiers. | custom |

| Templates | Ce que ça fait | Source |
|---|---|---|
| [`docs/`](templates/docs/README.md) | Squelette `docs/` d'un projet : architecture, décisions (variante ADR), modules. | custom |

| Automation | Ce que ça fait | Source |
|---|---|---|
| [`release-notes`](meta/automation/release-notes/generate.sh) | Brouillon de release notes en CI par script déterministe, sans appel API (workflow [`release-notes.yml`](.github/workflows/release-notes.yml), déclenchement manuel). | custom ([ticket 20](meta/tickets/20/)) |

## Origine et statut

Généralisé à partir d'une dizaine de projets réels (fronts Angular, backs Spring Boot/Kotlin,
services Python, infra, migration de données). Certains fichiers restent liés à un type d'infra
précis plutôt que génériques à outrance : le détail concret est ce qui évite l'erreur. Alimenté au
fil de l'eau ; un skill ou un agent n'est stable qu'une fois éprouvé en conditions réelles.
