# Travail en parallèle et sans surveillance

Faire avancer plusieurs chantiers en même temps sans que leurs éditions se marchent dessus, et
lancer Claude depuis un script. Flags et commandes vérifiés dans la doc officielle
(`best-practices`, `cli-reference`, `commands`, `worktrees`, `headless`, `code-mode`) le 2026-11-26.

## Avant un run sans surveillance

Cinq questions, pour la tâche précise :

1. **Sait-il à quoi ressemble « fini » ?** Une condition `/goal`, un `SPEC.md`, un test rouge à
   passer au vert (voir [`verification.md`](verification.md)).
2. **Peut-il vérifier son travail ?** Suite de tests, hook `Stop`, étape de revue.
3. **Que peut-il toucher ?** Règles de permission, `dontAsk`, sandbox, une worktree, la seule
   branche où il peut écrire (voir [`permissions.md`](permissions.md)).
4. **Qu'est-ce qui l'arrête ?** `--max-turns`, `--max-budget-usd`.
5. **Où va le résultat, et qui valide ?** Une PR, un commentaire, un résumé — puis un humain qui
   approuve le merge ou le déploiement.

## Worktrees

- `claude -w <nom>` (`--worktree`) démarre une session dans une nouvelle worktree git, sur sa
  propre branche — un terminal par chantier. Le dépôt doit avoir au moins un commit.
- Une worktree est un checkout neuf : fichiers ignorés (`.env`) absents, dépendances non
  installées. Lister les petits fichiers ignorés nécessaires dans `.worktreeinclude` à la racine
  (syntaxe `.gitignore`, copiés, pas liés) ; pour un gros dossier, le réglage
  `worktree.symlinkDirectories`, ou la commande d'install dans `CLAUDE.md`.
- Nettoyage : une worktree sans changement est retirée à la sortie d'une session non nommée ;
  celle d'un `claude -p --worktree` est à retirer soi-même (`git worktree remove <chemin>`).

## `/batch` : un gros changement mécanique

`/batch <instruction>` découpe le travail en 5 à 30 unités indépendantes, montre le plan, puis après
approbation lance un sous-agent par unité, chacun dans sa worktree (hors dépôt git : v2.1.281+).
Pour un changement répétitif sur beaucoup de fichiers (migration d'API), pas pour une
fonctionnalité dont les parties dépendent les unes des autres.

## Boucle `claude -p` sur une liste de fichiers

```bash
for file in $(cat files.txt); do
  claude --bare -p "Migre $file vers <nouvelle API>. Réponds OK ou FAIL." \
    --allowedTools "Read,Edit,Bash(<commande de test> *)" \
    --permission-mode dontAsk \
    --max-turns 20
done
```

- **Lancer d'abord sur 2-3 fichiers**, regarder ce qui casse, corriger le prompt, puis le reste —
  même principe que « un seul élément d'abord » de [`general-coding.md`](general-coding.md#changements).
- `--bare` ignore hooks, skills, plugins, MCP et `CLAUDE.md` (et le login claude.ai : clé API ou
  `apiKeyHelper`) ; ne pas l'utiliser si le run a besoin d'un hook.
- `--output-format json` donne un seul objet résultat à parser en CI ; `stream-json` + `--verbose`
  pour suivre les événements.
- Commit : l'exemple officiel fait committer chaque run. À n'autoriser (`Bash(git commit *)` dans
  `--allowedTools`) que sur une branche ou une worktree dédiée, avec merge par un humain — jamais
  sur la branche de travail partagée.

## Relecteur indépendant

Une seconde session est le relecteur indépendant le plus simple : l'une écrit, l'autre relit le
fichier sans avoir vu son écriture, et on recolle les remarques dans la première (pattern
Writer/Reviewer). Même idée que `/code-review`, avec l'humain comme messager.

## Code Mode (expérimental)

Claude écrit un script JavaScript qui enchaîne plusieurs appels d'outils en une étape. Expérimental,
désactivé par défaut, « may change or be removed in any release » ; v2.1.323+,
`CLAUDE_CODE_EXPERIMENTAL_CODE_MODE=1`. À tester, pas à recommander dans un projet.
