# OpenAI Codex setup — release notes

Setup à faire une seule fois, par la personne qui active cette intégration sur son fork/repo. Voir
[`AGENTS.md`](../../../AGENTS.md) pour le rôle de Codex sur ce repo et le workflow
[`codex-release-notes.yml`](../../../.github/workflows/codex-release-notes.yml) pour le détail
technique.

## 1. Créer un projet OpenAI dédié + une clé API

1. Se connecter sur [platform.openai.com](https://platform.openai.com/).
2. Créer un **projet** dédié à cette automatisation (ex. `ai-playbook-automation`) plutôt que de
   réutiliser un projet/clé personnel existant — isole le budget et la révocation de tout autre
   usage.
3. Dans ce projet, générer une **clé API** (`Settings` → `API keys` → `Create new secret key`).
   Restreindre les permissions de la clé aux capacités nécessaires si l'interface le permet (accès
   Responses API uniquement).
4. Copier la clé immédiatement (elle n'est affichée qu'une fois) — ne la coller nulle part dans ce
   repo, dans un commit, ou dans un message partagé.

## 2. Ajouter le secret GitHub

1. Sur GitHub : `Settings` → `Secrets and variables` → `Actions` → `New repository secret`.
2. Nom : `OPENAI_API_KEY`.
3. Valeur : la clé copiée à l'étape précédente.
4. Enregistrer. Aucun autre secret n'est nécessaire pour ce workflow.

## 3. Déclencher le workflow

`Actions` → `Codex release notes` → `Run workflow`, avec en entrée :

- `to_ref` : ref/tag de fin (défaut `HEAD`) ;
- `from_ref` : ref/tag de départ, exclu (laisser vide pour prendre automatiquement le dernier tag
  avant `to_ref` — échoue explicitement si aucun tag n'est trouvé).

Exemple, une fois qu'un deuxième tag existera sur ce repo :

```text
from_ref : 0.1.0
to_ref   : 0.2.0
```

En attendant (un seul tag `0.1.0` existe actuellement sur ce repo), tester avec un commit ancien en
guise de `from_ref`, par exemple :

```text
from_ref : 4d5d4b6
to_ref   : HEAD
```

Le résultat (`release-notes.md`) est disponible dans l'onglet `Summary` du run, section
`Artifacts`, une fois le job terminé.

## Coûts

Facturation à l'usage (pay-as-you-go), pas d'abonnement ChatGPT nécessaire. Un run typique (quelques
dizaines à quelques centaines de commits en entrée) coûte de l'ordre de quelques centimes à ~1 $
avec les tarifs actuels des modèles Codex — à vérifier au moment du run sur
[developers.openai.com/api/docs/pricing](https://developers.openai.com/api/docs/pricing) (tarifs
évolutifs). Aucun coût tant que le workflow n'est pas déclenché manuellement.

## Retirer l'intégration

Réversible : supprimer `.github/workflows/codex-release-notes.yml`, `meta/automation/release-notes/`,
`AGENTS.md`, puis le secret `OPENAI_API_KEY` côté GitHub et la clé/le projet côté OpenAI. Aucun
autre fichier du repo n'en dépend.
