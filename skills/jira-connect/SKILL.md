---
name: jira-connect
description: >
  Configure et teste la connexion au Jira auto-hébergé de gouv.nc (jira.gouv.nc), par Personal
  Access Token (API REST, mode principal) ou par cookie de session manuel (sans PAT), et permet de
  récupérer un ticket par sa clé. Se déclenche pour "connecte-toi à Jira", "teste la connexion
  Jira", "récupère le ticket JIRA depuis Jira", "configure l'accès Jira", "connexion Jira sans
  token".
---

# Connexion à jira.gouv.nc

Jira **Data Center/Server auto-hébergé**, pas d'OAuth ni d'API token façon Atlassian Cloud
(gouv.nc n'est pas sur `*.atlassian.net`, cf. `jira.gouv.nc` qui renvoie une page de login
classique aux tentatives d'accès non authentifiées). Deux modes :

- **Mode A — Personal Access Token** (principal, scriptable, voir ci-dessous) — nécessite de créer
  un PAT ; c'est le mode à utiliser par défaut.
- **Mode B — Cookie de session** (voir plus bas) — sans PAT, manuel (pas de popup automatique, voir
  pourquoi dans cette section). À réserver au cas où l'utilisateur ne peut/veut vraiment pas créer
  de PAT.

> Ce skill est spécifique à `jira.gouv.nc` (infra réellement partagée par tous les projets
> gouv-nc), pas à un tracker générique — copier tel quel dans chaque repo gouv-nc, adapter
> l'URL/le tracker si utilisé ailleurs.

## Mode A — Personal Access Token

Config stockée dans `.claude/jira.env` — jamais committée (`.claude/*.env` exclu localement, voir
`CLAUDE.md` du projet). Config **propre à chaque repo** : ne pas supposer qu'une config déjà faite
sur un autre projet gouv-nc s'applique ici — chaque dépôt a son propre `.claude/`, jamais partagé
entre repos, même si le PAT sous-jacent (créé une fois sur `jira.gouv.nc`) est réutilisable tel
quel d'un repo à l'autre.

### 1. Configuration (une fois par poste et par repo)

Chercher `.claude/jira.env` :

- **S'il existe** : `set -a && source .claude/jira.env && set +a`, passer à l'étape 2.
- **Sinon** : demander à l'utilisateur `JIRA_BASE_URL` (ex. `https://jira.gouv.nc`, sans slash
  final) et un Personal Access Token (Jira → avatar en haut à droite → *Personal Access Tokens* →
  *Create token*) — s'il en a déjà créé un pour un autre projet gouv-nc, il peut le réutiliser tel
  quel, seul le fichier de config est propre à ce repo. Écrire dans `.claude/jira.env` :
  ```
  JIRA_BASE_URL=https://jira.gouv.nc
  JIRA_PAT=<token>
  ```
  Ne jamais afficher le token en clair dans une sortie susceptible d'être partagée/loggée au-delà
  de cette session.

### 2. Test de connexion

```bash
curl -s -o /tmp/jira-myself.json -w "%{http_code}" \
  -H "Authorization: Bearer $JIRA_PAT" \
  "$JIRA_BASE_URL/rest/api/2/myself"
```

Endpoint `myself` : ne nécessite aucune permission particulière au-delà d'être authentifié, standard
pour un test de connectivité.

- **200** : connexion OK — lire `/tmp/jira-myself.json` (`displayName`, `emailAddress`) et confirmer
  à l'utilisateur avec l'identité retournée (preuve que ce n'est pas un faux positif).
- **401/403** : token invalide, expiré, ou révoqué — les PAT Jira ont une durée de vie configurable
  (souvent limitée à quelques mois) ; proposer d'en régénérer un.
- **Timeout / connexion refusée** : probablement un réseau interne gouv.nc, accès hors VPN — demander
  à l'utilisateur s'il faut être connecté à un VPN/réseau spécifique avant de conclure à un problème
  de token.
- **Erreur SSL/certificat** : possible CA interne non reconnu par le trust store système — **ne
  jamais contourner avec `curl -k`/`--insecure` sans validation explicite de l'utilisateur** (risque
  MITM sur un secret d'authentification).
- **404 sur `/rest/api/2/myself`** : vérifier `JIRA_BASE_URL` (chemin de base Jira parfois sous un
  sous-répertoire, ex. `/jira`) plutôt que de conclure à une indisponibilité du service.

### 3. Récupérer un ticket par sa clé

Une fois la connexion validée :

```bash
curl -s -H "Authorization: Bearer $JIRA_PAT" "$JIRA_BASE_URL/rest/api/2/issue/<CLE>"
```

`<CLE>` = ex. `RUE-316`, `GUE-4494`. Réponse JSON complète (résumé, description, statut,
commentaires...).

Branché sur le skill [`start-ticket`](../start-ticket/SKILL.md) (étape 1) : quand l'utilisateur ne
fournit qu'un ID de ticket sans contenu collé, `start-ticket` tente cette récupération
automatiquement, avec repli sur le mode manuel (copier-coller) si `.claude/jira.env` est absent ou
la requête échoue.

### Sécurité (mode A)

- `JIRA_PAT` ne doit jamais apparaître dans un fichier trackable par git, un message de commit, ou
  une sortie destinée à être partagée (issue, PR, capture d'écran).
- Un PAT Jira porte les mêmes droits que l'utilisateur qui l'a créé — le traiter comme un mot de
  passe.

## Mode B — Cookie de session (sans PAT)

**Pas un flux OAuth automatique** : le flux "popup de connexion qui revient toute seule avec un
token" marche dans certains outils (Bruno sur `local-keycloak`, `gh auth login`, `claude mcp add`)
parce qu'une app OAuth y est déjà enregistrée avec une redirect URI utilisable — rien de tel
n'existe côté Jira gouv.nc, et ça demanderait une action d'un admin Jira (Application Links) pour
exister. Seule l'approche manuelle ci-dessous est réaliste (à revérifier si `claude-in-chrome` est
installé un jour : une lecture directe des pages dans un navigateur piloté redeviendrait
envisageable).

### Étapes

1. L'utilisateur se connecte à `$JIRA_BASE_URL` dans **son propre navigateur** (normalement, pas
   d'action de ma part).
2. Il récupère le cookie `JSESSIONID` (DevTools → Application/Storage → Cookies → `jira.gouv.nc`)
   et le communique.
3. Test/usage :
   ```bash
   curl -s -H "Cookie: JSESSIONID=<valeur>" "$JIRA_BASE_URL/rest/api/2/myself"
   ```
   Même endpoint de test qu'en mode A, auth par cookie de session plutôt que par `Authorization:
   Bearer`.

### Quand utiliser ce mode plutôt que le mode A

- L'utilisateur n'a pas de PAT et ne veut pas en créer un (droits insuffisants, préférence).
- Le compte n'a pas la permission Jira de créer des Personal Access Tokens (certains profils
  restreints l'interdisent).

### Limites

- **Manuel, pas automatique** — pas de popup qui s'ouvre tout seul (voir ci-dessus).
- Cookie de session à durée de vie courte (expire bien avant un PAT) — à refaire à chaque
  expiration, pas adapté à un usage répété/scriptable comme le mode A.
- Ne pas stocker ce cookie dans `.claude/jira.env` comme le PAT (durée de vie trop courte pour que
  ce soit utile) — le demander à l'utilisateur à chaque usage plutôt que de le persister.
