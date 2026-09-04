# #15 — Intégrer OpenAI Codex comme moteur d'automatisation (release notes)

> Ticket = issue GitHub [#15](https://github.com/zYmMiJ/ai-playbook/issues/15) — convention réelle
> de ce repo (voir `feature/1-sync-kanban-action` → issue #1), pas le format `<PREFIX>-<NUM>`
> générique documenté dans `skills/start-ticket/SKILL.md` (celui-ci vise les projets consommateurs
> avec un tracker externe type Jira).

## Contexte

`ai-playbook` documente déjà une séparation claire entre deux familles d'outils IA. Aujourd'hui
seul le premier existe :

```
Claude Code
    ↓
développement interactif (analyse, architecture, implémentation, debugging, tests, refactoring)

Codex
    ↓
automatisations répétitives et vérifiables — n'existe pas encore sur ce repo
```

Cette US introduit Codex dans le repo **uniquement** comme moteur d'automatisation CI, sans créer
un second assistant de développement général. Elle sert aussi de test grandeur nature de
l'intégration Codex/GitHub Actions, avec un cas d'usage volontairement restreint pour valider
l'authentification, les permissions et le pattern avant d'en ajouter d'autres.

## Problème

- `skills/generate-release-note/SKILL.md` documente une génération de release notes **manuelle**,
  faite par Claude Code en session interactive à la demande de l'utilisateur.
- Rien n'automatise cette tâche répétitive et à faible risque (elle ne fait que lire l'historique
  Git et écrire un fichier Markdown).
- Aucune intégration Codex n'existe sur ce repo (pas de `.github/workflows/`, pas d'`AGENTS.md`,
  pas de secret configuré) — il faut la construire de zéro.
- Le besoin est de **valider Codex progressivement et sans risque** : lecture seule, déclenchement
  manuel, sortie en artifact, avant d'envisager toute automatisation plus large ou plus permissive.

## Objectif

Permettre à un workflow GitHub Actions déclenché manuellement d'utiliser Codex pour générer des
release notes à partir de sources vérifiables du repository (historique Git, tags), et produire un
fichier Markdown récupérable comme artifact — sans toucher au repository lui-même.

## Hors scope

Explicitement **non couvert** par cette US :

- Développement applicatif avec Codex (Codex ne remplace pas Claude Code sur l'analyse/l'implémentation).
- Modification automatique du code par Codex.
- Push automatique (le workflow n'a que `contents: read`).
- Merge automatique de PR.
- Publication automatique en production ou création automatique de GitHub Release.
- Automatisation générale de tous les workflows IA du repo — un seul cas d'usage (release notes),
  les suivants seront des US séparées une fois ce pattern validé.

## Analyse de l'existant

- **Pas de `CLAUDE.md` à la racine** — ce repo est un playbook à copier/adapter, pas un projet qui
  applique ses propres règles à lui-même. `README.md` joue ce rôle d'entrée principale, complété par
  `.claude/settings.json` (hooks) et `rules/*.md` (à piocher, pas à appliquer tel quel ici).
- **`.claude/`** — seulement des hooks (`block-banwords.py` en `PreToolUse` sur Write/Edit,
  `check-inventory.py` en `Stop`). Aucun agent/skill `.claude/` local : `agents/` et `skills/` à la
  racine sont la **source** à copier dans les projets cibles, pas une config active sur ce repo.
- **Aucun workflow GitHub Actions existant** (`.github/workflows/` n'existe pas). Un script de
  synchronisation kanban (`sync-kanban`) avait été tenté puis **retiré** (`68215b5`) au profit des
  automatisations natives GitHub Projects v2 — précédent notable : ce repo préfère la solution
  native/officielle la plus simple à un script custom à maintenir, cohérent avec la démarche de
  cette US (privilégier l'action officielle Codex à un wrapper maison).
- **Convention de tickets** (`skills/start-ticket/SKILL.md`) : `tickets/<ID>/analyse.md` +
  `plan.md`, statut en tête de `plan.md` (`à valider`/`validé`/`en implémentation`/`implémenté`).
  Ce repo n'a pas de tracker externe : les tickets sont les issues GitHub elles-mêmes — ID = numéro
  d'issue (`#15`), pas de reconstruction depuis un ticket tiers.
- **Scripts existants** : `skills/update-api-collections/scripts/` (Node, pour un projet cible, pas
  pour ce repo), `.claude/hooks/*.py` (hooks locaux). Rien de réutilisable pour cette US.
- **Mécanismes de release existants** : `skills/release/SKILL.md` (tag Git, jamais exécuté par
  Claude) + `skills/generate-release-note/SKILL.md` (notes de release **manuelles**, écrites après
  validation d'une release en environnement, dans `docs/releases/X.Y.Z.md` + entrée dans
  `docs/releases/README.md`). Cette US ne remplace pas ce mécanisme : elle prépare une brique qui
  pourra, plus tard, générer un **brouillon** de ces notes — mais reste pour l'instant un artifact
  CI séparé, pas une écriture dans `docs/releases/`.

## Analyse des solutions Codex

Recherche faite sur la documentation officielle actuelle (`developers.openai.com/codex`, dépôts
`openai/codex` et `openai/codex-action`) :

| Option | Avantages | Inconvénients | Complexité | Sécurité | Maintenance | Pertinence MVP |
|---|---|---|---|---|---|---|
| **`openai/codex-action@v1`** (officielle) | Installe/configure Codex, démarre un proxy pour l'API key (la clé n'est jamais exposée à `codex exec` en clair dans le step), profils de permission prêts à l'emploi (`:read-only`, `:workspace`), `output-file` natif | Action tierce à versionner (`@v1`), un peu de surface de config à apprendre | Faible — un seul step YAML | **Bonne** — proxy + sandbox + `safety-strategy` (`drop-sudo` par défaut, `read-only` disponible) | Faible — maintenue par OpenAI | **Retenue** |
| **`codex exec` en CLI nu** (installer le binaire soi-même + appeler `codex exec`) | Contrôle total, pas de dépendance à une action tierce | Il faut exposer `OPENAI_API_KEY` directement à un step shell — la doc officielle **déconseille** explicitement ce pattern en CI au profit de l'action | Moyenne — install + wiring manuel | Moindre (clé en clair dans l'environnement du step) | Plus élevée (suivre les releases du CLI soi-même) | Rejetée pour ce MVP |
| **Codex CLI en local/poste dev** | Pertinent pour un usage interactif | Hors sujet : le besoin est une automatisation **CI**, pas un outil de poste | — | — | — | Hors scope |
| **SDK Codex (Node/Python)** | Intégration fine possible dans un script custom | Sur-ingénierie pour un besoin qui tient en un prompt + un `git log` — recréerait un wrapper que le repo a justement évité pour le kanban (`68215b5`) | Élevée | Dépend de l'implémentation | Élevée | Rejetée |
| **Appel direct à l'API Responses** | Flexibilité maximale | Réinvente ce que l'action officielle fait déjà (proxy, sandbox, parsing de sortie) | Élevée | À charge de l'implémentation | Élevée | Rejetée |

**Décision** : `openai/codex-action@v1`, en mode non-interactif (`codex exec` en interne),
`permission-profile: ':read-only'` — cohérent avec un besoin en lecture seule (voir Architecture).

## Authentification

- **Méthode recommandée par la doc officielle** : `openai-api-key` en entrée de l'action, alimentée
  depuis un **secret GitHub** — jamais une clé exposée directement à un step shell.
- **Clé API classique vs service account** : pour ce volume (déclenchement manuel, quelques appels)
  une clé API "projet" suffit. Bonne pratique constatée (aide OpenAI + guides sécurité) : créer un
  **projet OpenAI dédié** (`ai-playbook-automation` par ex.) avec sa propre clé plutôt que de
  réutiliser une clé personnelle/partagée avec d'autres usages — isole le budget et la révocation
  d'un usage à l'autre. Une clé de type "service account" projet (si l'organisation OpenAI la
  propose) est préférable à une clé liée à un compte personnel, pour ne pas dépendre d'un individu.
- **Secret GitHub à créer** : `OPENAI_API_KEY` (nom conventionnel, utilisé tel quel par l'input
  `openai-api-key` de l'action). Un seul secret, au niveau du repo (pas d'environnement GitHub
  dédié nécessaire pour ce MVP — pas de déploiement, pas d'approbation manuelle à gagner).
- **Moindre privilège** :
  - Côté OpenAI : clé scoping projet dédié, sans accès aux autres capacités de la plateforme
    (embeddings, fine-tuning...) si l'interface de gestion des clés le permet — à restreindre à
    l'usage Responses API.
  - Côté GitHub : `permissions: contents: read` au niveau du workflow, aucun autre scope. Pas de
    `pull-requests: write`/`issues: write` — ce MVP ne commente rien, ne modifie rien.
  - Côté Codex : `permission-profile: ':read-only'` — Codex ne peut pas écrire dans le repo ni
    accéder au réseau depuis le sandbox ; le fichier de sortie est écrit par l'action elle-même
    (`output-file`), pas par une mutation faite par Codex.
- **Coût potentiel** : facturation à l'usage (pay-as-you-go), pas d'abonnement ChatGPT nécessaire.
  Un run de génération de release notes reste petit (quelques dizaines à quelques centaines de
  commits en entrée, une sortie de quelques centaines de lignes) → de l'ordre de quelques centimes
  à ~1 $ par run avec les tarifs actuels des modèles Codex. Tarifs à vérifier au moment du run sur
  `developers.openai.com/api/docs/pricing` (ils évoluent). Aucun coût tant que le workflow n'est pas
  déclenché (`workflow_dispatch` uniquement).

## Architecture proposée

```
workflow_dispatch (from_ref, to_ref)
        │
        ▼
checkout (fetch-depth: 0, tags inclus)
        │
        ▼
résolution de la plage (from_ref auto = dernier tag si non fourni)
        │
        ▼
git log <from_ref>..<to_ref> --no-merges   → contexte Git brut
        │
        ▼
assemblage : automation/release-notes/prompt.md (règles, invariant)
           + contexte Git (variable, généré à chaque run)
        │
        ▼
openai/codex-action@v1 (permission-profile: :read-only, codex exec en interne)
        │
        ▼
release-notes.md (écrit par l'action via output-file)
        │
        ▼
actions/upload-artifact — release-notes.md disponible en téléchargement
```

Pas d'écriture dans `docs/releases/` par ce workflow : la génération humaine validée reste le
mécanisme de référence (`skills/generate-release-note`). Ce MVP produit un **brouillon consultable**,
pas une source de vérité publiée — cohérent avec "Codex ne doit jamais inventer un changement
fonctionnel" et avec l'absence de droit d'écriture sur le repo.

## Risques

- **Hallucination de changements** — mitigé par : prompt qui interdit explicitement d'inventer,
  contexte limité au `git log` réel (pas d'accès réseau/web depuis le sandbox `:read-only`), sortie
  jamais publiée automatiquement (artifact à relire, pas un commit/une release).
- **Fuite de secret** — mitigé par : `OPENAI_API_KEY` uniquement en `${{ secrets.* }}`, jamais en
  clair dans le YAML ni dans un fichier versionné ; l'action officielle passe par un proxy plutôt
  que d'exposer la clé à `codex exec` directement.
- **Permissions GitHub trop larges** — mitigé par `permissions: contents: read` au niveau workflow,
  aucun droit d'écriture.
- **Coût API** — mitigé par déclenchement manuel uniquement (pas de trigger automatique sur push),
  volume par run limité (un seul `git log` entre deux refs, pas tout l'historique par défaut).
- **Duplication avec Claude** — mitigé par le scope : `skills/generate-release-note` reste le
  mécanisme validé humain pour la doc officielle (`docs/releases/`) ; ce workflow produit un
  brouillon CI séparé, pas un remplacement.
- **Dépendance à un provider externe** — accepté : c'est l'objet même de l'US. Réversible (voir
  `plan.md` — supprimer le workflow, `AGENTS.md` et le secret suffit à retirer l'intégration).
- **Contexte Git incomplet** — mitigé par `fetch-depth: 0` au checkout (historique complet + tags),
  et par un échec explicite (`exit 1`) si `from_ref` ne peut pas être résolu automatiquement plutôt
  que de deviner une plage.

## Décision recommandée

Adopter `openai/codex-action@v1` en mode `permission-profile: ':read-only'`, déclenché uniquement en
`workflow_dispatch`, avec un unique secret `OPENAI_API_KEY` scoping un projet OpenAI dédié à cette
automation. Un seul cas d'usage pour ce MVP (release notes), `AGENTS.md` minimal à la racine pour
cadrer Codex sans dupliquer `README.md`/`rules/`. Pas de script wrapper, pas de SDK — la CLI/action
officielle suffit intégralement au besoin. Voir `plan.md` pour le détail d'implémentation et le
challenge de cette architecture.
