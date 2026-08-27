# Hooks

Un hook garantit qu'une action se produit **à chaque fois**, sans exception — contrairement à
`CLAUDE.md` (indicatif : suivi ou pas selon le contexte). Utile pour un contrôle qui doit
*toujours* passer, pas juste "en général".

## Comment ça marche

Un hook se déclare dans `settings.json`/`settings.local.json`, sous `hooks.<ÉVÉNEMENT>`, avec un
`matcher` (quel outil) et une commande shell à exécuter. Événements les plus utiles :

- `PostToolUse` (matcher `Write|Edit`) : après chaque édition — le candidat naturel pour un
  contrôle de compilation ou de format rapide.
- `PreToolUse` (matcher `Bash`) : avant une commande shell — pour bloquer ou logger certaines
  commandes.
- `Stop` : quand Claude termine son tour — pour un résumé ou une vérification de fin de tâche.

## Gabarit : compilation rapide après édition

Préférer un contrôle **rapide** (compilation/typecheck, pas la suite de tests complète) à chaque
édition — une suite avec setup lourd (containers, DB) casse le flow si elle tourne à chaque
fichier sauvegardé. Réserver la suite complète à un moment explicite (fin de tâche, avant commit),
pas à chaque `Write`/`Edit`.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "python3 -c \"import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path') or d.get('tool_response',{}).get('filePath',''))\" | { read -r f; case \"$f\" in *.<EXT>) (cd <CHEMIN_DU_PROJET> && <COMMANDE_DE_COMPIL_RAPIDE>) ;; esac; } 2>&1 | tail -30",
            "timeout": 30,
            "statusMessage": "Compilation rapide..."
          }
        ]
      }
    ]
  }
}
```

Adapter `<EXT>` (extension du fichier édité), `<CHEMIN_DU_PROJET>`, `<COMMANDE_DE_COMPIL_RAPIDE>`
(ex. `mvn -q -o compile`, `tsc --noEmit`, `go build ./...`). Le `case "$f" in *.<EXT>)` évite de
déclencher la commande sur un fichier hors périmètre (doc, config...). Vérifier que l'outil utilisé
pour parser le JSON stdin (`python3` ci-dessus) est bien disponible sur le poste — sinon substituer
`jq` ou équivalent.

**Pour l'activer** : copier ce bloc dans `.claude/settings.local.json` (fusionner avec la clé
`hooks` si elle existe déjà), puis ouvrir `/hooks` une fois pour que Claude Code recharge la
config (le watcher ne surveille que les dossiers qui avaient déjà un fichier de settings au
démarrage de la session).

## Autres idées

- `PreToolUse` sur `Bash`, matcher type `Bash(git push*)` : bloquer/confirmer un push direct sur
  la branche par défaut.
- `PostToolUse` sur `Write|Edit`, filtré sur un chemin sensible (migrations DB, config d'infra) :
  rappel/alerte quand ce type de fichier est touché.
- `Stop` : résumé automatique des fichiers modifiés dans le tour, pour relecture rapide avant de
  committer soi-même.
