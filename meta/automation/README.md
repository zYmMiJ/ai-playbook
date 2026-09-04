# OpenAI Codex — setup général

Setup pour la **prochaine** automatisation qui appellera réellement Codex — aucun workflow actif
sur ce repo n'en a besoin aujourd'hui (voir [`AGENTS.md`](../../AGENTS.md), section "Codex
responsibilities" : release notes utilisait Codex jusqu'à
[issue #20](https://github.com/zYmMiJ/ai-playbook/issues/20), qui l'a remplacé par un script
déterministe — la tâche n'a jamais eu besoin d'un modèle). Gardé prêt plutôt que retiré, pour éviter
un aller-retour de configuration (clé/projet OpenAI, secret GitHub) le jour où un vrai cas d'usage
Codex apparaît.

## 1. Créer un projet OpenAI dédié + une clé API

> Un abonnement **ChatGPT Plus** (20 $/mois) ne donne **pas** accès à l'API — ce sont deux comptes
> de facturation séparés sur le même compte OpenAI. Il faut passer par
> [platform.openai.com](https://platform.openai.com/) (pas chat.openai.com) et y ajouter une carte
> bancaire en facturation **pay-as-you-go**, indépendante des 20 $/mois ChatGPT.

1. Se connecter sur [platform.openai.com](https://platform.openai.com/).
2. Créer un **projet** dédié à cette automatisation (ex. `ai-playbook-automation`) plutôt que de
   réutiliser un projet/clé personnel existant — isole le budget et la révocation de tout autre
   usage.
3. Dans ce projet, définir une **limite de dépense** (`Settings` → `Limits`, ou `Billing` →
   `Usage limits` selon l'interface courante) — un plafond mensuel bas (ex. quelques dollars)
   suffit largement pour une automatisation ponctuelle et borne les dégâts en cas de fuite de la
   clé, indépendamment de toute autre mesure ci-dessous.
4. Générer une **clé API** (`Settings` → `API keys` → `Create new secret key`), rattachée à ce
   projet. Restreindre les permissions de la clé aux capacités nécessaires si l'interface le permet
   (accès Responses API uniquement).
5. Copier la clé immédiatement (elle n'est affichée qu'une fois) — ne la coller nulle part dans ce
   repo, dans un commit, un fichier de log, une issue/PR ou un message partagé (Slack, email...).
   Si elle a été collée par erreur quelque part, considérer la clé compromise et passer directement à
   [Rotation / révocation](#rotation--révocation) ci-dessous, effacer l'historique n'est pas
   suffisant.

## 2. Ajouter le secret GitHub

1. Sur GitHub : `Settings` → `Secrets and variables` → `Actions` → onglet **Secrets** (pas
   **Variables** : un secret est masqué dans les logs, une variable ne l'est pas) → `New repository
   secret`.
2. Nom : `OPENAI_API_KEY`.
3. Valeur : la clé copiée à l'étape précédente.
4. Enregistrer.
5. Scope volontairement **repo-only**, pas un secret **organisation** — même si plusieurs repos
   utilisaient Codex un jour, un secret par repo limite le rayon d'exposition en cas de compromission
   d'un seul d'entre eux. Ne pas dupliquer non plus la valeur dans une variable d'environnement
   `Actions` (onglet **Variables**) : les variables ne sont pas masquées dans les logs.

## Garde-fous attendus de tout futur workflow Codex

Ce que le workflow release-notes (#15, retiré depuis) appliquait déjà — à reproduire pour la
prochaine automatisation :

- `permissions: contents: read` au niveau du workflow (rien de plus, sauf besoin explicite et
  documenté).
- Déclenchement `workflow_dispatch` uniquement, jamais sur PR externe/fork — sinon le secret est
  exposé à du code non fiable.
- La clé injectée directement dans l'input de l'action utilisée (jamais `echo`/`print` d'un secret
  dans un step — GitHub le masque dans les logs, mais autant ne jamais le manipuler explicitement).
- `permission-profile`/équivalent en lecture seule côté Codex si l'action le permet (ex.
  `openai/codex-action@v1` avec `':read-only'`) — le fichier de sortie doit être écrit par l'action
  du workflow, pas par Codex lui-même.

## À la charge de la personne qui active une intégration Codex

- Ne jamais committer la clé, y compris temporairement pour tester en local (`codex exec` en local
  utilise une variable d'environnement shell, jamais un fichier versionné).
- Revue périodique : vérifier de temps en temps (`Settings` → `API keys` côté OpenAI) qu'aucune
  clé inattendue n'existe sur le projet, et que l'usage facturé correspond aux runs réellement
  déclenchés.

### Rotation / révocation

À faire immédiatement si la clé a fuité (log accidentel, capture d'écran partagée, poste
compromis...), et en bonne pratique périodiquement sinon :

1. Sur [platform.openai.com](https://platform.openai.com/), projet dédié : révoquer l'ancienne clé
   (`API keys` → supprimer) — effet immédiat, aucune confirmation de fuite nécessaire pour agir.
2. Générer une nouvelle clé (même procédure qu'à la création, étape 1 ci-dessus).
3. Sur GitHub : `Settings` → `Secrets and variables` → `Actions` → `OPENAI_API_KEY` → `Update` avec
   la nouvelle valeur. Pas besoin de supprimer/recréer le secret, juste de remplacer sa valeur.
4. Aucune autre étape : un futur workflow Codex relira `secrets.OPENAI_API_KEY` à chaque run.

## Retirer l'intégration

Réversible : supprimer ce fichier et la section "Codex responsibilities" d'
[`AGENTS.md`](../../AGENTS.md), puis le secret `OPENAI_API_KEY` côté GitHub et la clé/le projet côté
OpenAI. Aucun fichier du repo n'en dépend tant qu'aucun workflow n'utilise Codex.
