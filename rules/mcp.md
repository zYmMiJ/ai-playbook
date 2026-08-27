# MCP

MCP (Model Context Protocol) connecte Claude Code à un outil/service externe — forge Git, tracker,
base de données, système de fichiers distant... Documenté ici pour le jour où un projet décide de
s'en servir ; même logique que [`hooks.md`](hooks.md) — un mécanisme réel, pas encore branché par
défaut, à activer projet par projet quand le besoin est concret.

## Ce que ça change concrètement

Sans MCP, toute interaction avec un service externe passe par la CLI de cet outil (`git`/`gh`,
`curl` + API REST...) ou se fait à la main dans le navigateur — voir par exemple
[`../skills/jira-connect/SKILL.md`](../skills/jira-connect/SKILL.md), qui fait exactement ça pour
Jira via API REST + PAT, sans MCP. Un serveur MCP donne à Claude un accès structuré direct à ce
service (lire une MR et ses commentaires, un ticket, une table) sans passer par un appel shell à
parser — l'intérêt croît avec la fréquence d'usage dans une session, pas systématique pour un
besoin ponctuel.

## Gabarit : brancher un serveur MCP

```bash
claude mcp add <NOM> \
  --transport stdio \
  -- npx -y <PACKAGE_SERVEUR_MCP>
```

Nécessite en général, en variables d'environnement (via `claude mcp add ... -e VAR=valeur`, ou le
`env` du fichier `.mcp.json` généré à la racine du repo) :

- `<TOKEN_VAR>` — token d'accès au service, avec le scope minimal nécessaire (lecture seule si ça
  suffit à l'usage prévu).
- `<URL_VAR>` — URL de l'instance si auto-hébergée (pas la valeur SaaS par défaut du package).

**Ne pas activer sans les deux éléments confirmés** (URL d'instance réelle + token) — ça ne se
devine pas depuis le repo. `claude mcp add` écrit la config dans `.mcp.json`, fichier séparé de ce
rule, à créer seulement le jour où c'est effectivement branché — ne pas le committer avec un token
en clair dedans (voir la config générée avant de commit).

## Idées de serveurs MCP courants (à évaluer par projet, non activés par défaut)

- **Forge Git** (GitLab/GitHub) — lire/commenter une MR/PR, son pipeline CI, sans repasser par
  `gh`/`git` en ligne de commande.
- **Base de données en lecture seule** — interroger la base du projet sans repasser par un client
  SQL à chaque fois. Redondant avec ce que `Bash` + le client CLI font déjà : priorité basse sauf
  usage très fréquent.
- **Serveur LSP** (langage du projet) — navigation de code plus précise (définitions, références)
  que la recherche par grep. À évaluer si la taille de la codebase le justifie.

Pour chacun : ne brancher que sur besoin réel constaté sur ce projet précis, pas par défaut à la
création du repo.
