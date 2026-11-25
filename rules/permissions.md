# Permissions et autonomie

Choisir ce que Claude peut faire sans demander, et rendre **garanti** ce qui ne doit jamais arriver.
Modes, clés et versions vérifiés dans la doc officielle (`permission-modes`, `permissions`,
`settings`, `sandboxing`, `best-practices`) le 2026-11-26.

## Modes

| Mode | Effet | Usage |
|---|---|---|
| `default` (affiché « manual ») | Demande avant la plupart des éditions, commandes, requêtes réseau | Repo sensible, découverte |
| `acceptEdits` | Éditions et commandes de fichiers courantes approuvées dans le dossier de travail | Itération rapide surveillée |
| `plan` | Lecture et proposition seulement, pas d'édition avant approbation | Analyse avant changement |
| `auto` | Tout s'exécute, un classifieur bloque en amont ce qui est risqué | Mode de départ des sessions interactives depuis v2.1.283 |
| `dontAsk` | Ce qui demanderait une confirmation est **refusé** ; seul ce qui est pré-approuvé passe | CI, scripts, environnements verrouillés |
| `bypassPermissions` | Tout s'exécute sans contrôle | Conteneur / VM isolés uniquement |

`Shift+Tab` fait tourner les modes en session (`dontAsk` n'est jamais dans le cycle) ;
`--permission-mode <mode>` au lancement ; `permissions.defaultMode` dans les settings. `auto` et
`bypassPermissions` **ne prennent pas effet** depuis `.claude/settings.json` ni
`.claude/settings.local.json` du projet : settings utilisateur/managed ou flag uniquement.

Auto mode réduit les demandes, il **ne garantit rien** (« does not guarantee safety ») : après 3
blocages d'affilée ou 20 au total, il repasse en mode avec demandes. Une limite énoncée en
conversation (« ne pousse pas avant ma relecture ») est lue par le classifieur, mais peut se perdre
à la compaction — ce qui compte va dans une règle.

## Règles allow / ask / deny

- Évaluées dans l'ordre **deny → ask → allow** ; la première qui correspond décide. Un `ask` qui
  correspond demande même si un `allow` plus précis correspond aussi.
- **Les deny rules tiennent dans tous les modes**, y compris `auto` et `bypassPermissions`. Les
  allow rules n'ont aucun effet en `bypassPermissions`.
- **Une ask rule qui nomme une commande** (`Bash(git commit *)`) demande toujours, y compris en
  auto mode (le classifieur ne l'approuve pas à la place de l'humain) ; en `dontAsk`, elle est
  refusée.
- Syntaxe `Outil` ou `Outil(spécificateur)` : `Bash(npm run test *)`, `Read(./.env)`.
  `Bash(ls:*)` équivaut à `Bash(ls *)`.
- Limite : une règle `Bash` compare le **texte** de la commande — `Bash(git push *)` n'arrête pas
  `git -C . push`. Pour un interdit strict, doubler d'un hook `PreToolUse` ou du sandbox.
- `/permissions` liste les règles et le fichier d'où chacune vient (et les refus récents d'auto
  mode) ; `/fewer-permission-prompts` propose une allowlist à partir des commandes en lecture
  réellement utilisées.

## Une règle « jamais » se pose en règle, pas en absence de permission

Une règle du type « Claude ne committe/pousse jamais » ne tient pas par la seule **absence** d'allow
rule : en auto mode, une commande sans règle part au classifieur, qui peut l'approuver. La poser
explicitement :

```json
{
  "permissions": {
    "ask": ["Bash(git commit *)"],
    "deny": ["Bash(git push *)", "Bash(gh pr merge *)"]
  }
}
```

- `ask` pour ce que l'humain valide au cas par cas (le commit, après avoir lu le message) ;
- `deny` pour ce qui reste toujours manuel (push, merge, tag, publication).

Dans `.claude/settings.json` (versionné, partagé) si c'est une règle du projet ; dans
`.claude/settings.local.json` si c'est une préférence personnelle.

## Sandbox

`/sandbox` (ou `sandbox.enabled: true`) isole les **commandes shell seulement** (Bash et enfants) :
écriture limitée au dossier de travail et au temp, réseau via un proxy limité aux domaines
autorisés (liste vide au départ). Les outils intégrés Read/Edit/Write, les serveurs MCP et les
hooks tournent hors sandbox. macOS, Linux et WSL2 (Linux : `bubblewrap` + `socat`) ; sur Windows
natif, pas de sandbox. Réduit le risque, n'est pas une frontière d'isolation complète.

## Sans surveillance (script, CI)

```bash
claude -p "<tâche>" --permission-mode dontAsk --allowedTools "Read" "Bash(npm test)"
```

- `--allowedTools` pré-approuve, `dontAsk` refuse tout le reste au lieu de bloquer sur une
  question.
- `permissions.denyInsteadOfPrompting: true` (v2.1.319+) : même effet « refuser au lieu de
  demander », mais **avec le mode courant** (auto, acceptEdits…) ; honoré seulement dans les
  settings utilisateur (`~/.claude/settings.json`), managed, ou via `--settings`.
- Les cinq questions à se poser avant de lancer, et la parallélisation :
  [`parallel-work.md`](parallel-work.md).
