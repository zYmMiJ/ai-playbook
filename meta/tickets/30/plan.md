Statut : implémenté

Branche : `feature/30-pratiques-agentic-coding`, depuis `develop`.

## Objectif

Intégrer les 10 pratiques de `analyse.md`, dans leur version vérifiée contre la doc officielle (pas
la formulation de départ quand la doc dit autre chose — voir « Écarts » dans `analyse.md`), sans
doublonner un fichier existant.

## Changements fichier par fichier

### Nouveaux fichiers

- `rules/verification.md` (pratique 1) — « fini » = un check pass/fail que Claude peut lancer et
  lire ; exemples (test, exit code de build, lint, diff contre fixture, capture d'écran) ; l'échelle
  de contrainte en 4 niveaux (consigne dans le prompt → `/goal <condition>` → hook `Stop` bloquant →
  relecteur en contexte vierge : `/code-review` ou agent dédié) avec quand passer au niveau suivant ;
  exiger la preuve (commande lancée + sortie), « ça compile » ≠ « ça marche », `/verify` pour lancer
  l'app ; la commande de check est la ligne la plus utile d'un `CLAUDE.md`. Renvoie à `hooks.md`
  pour le gabarit, ne le recopie pas.
- `rules/session-management.md` (pratiques 2 et 4, part compaction de 3) — un chantier = une session
  (`claude -n <nom>` / `/rename`, `claude --resume <nom>`, `/clear <nom>`) ; `/clear` entre tâches
  sans rapport et après 2 corrections ratées ; `Esc`, `/rewind` / `Esc Esc` (4 restaurations +
  « summarize from/up to here »), checkpoints ≠ git (modifs Bash non suivies) ; `/btw` ; `/compact
  <focus>` et ce qui survit à la compaction (CLAUDE.md racine ré-injecté, consignes données seulement
  en conversation perdues → les mettre dans `CLAUDE.md`) ; plan mode (`Shift+Tab`, `--permission-mode
  plan`, `Ctrl+G`), séquence explorer → planifier → coder → committer, plan sauté si le diff se
  décrit en une phrase ; grosse fonctionnalité → interview → `SPEC.md` → **nouvelle session**.
  La section « Découpage de session » de `context-efficiency.md` y est **déplacée** (lien laissé).
- `rules/permissions.md` (pratique 7) — modes et quand les utiliser ; auto mode (défaut interactif
  v2.1.283+, ne se règle pas depuis les settings projet, ne garantit rien) ; allow/ask/deny et
  précédence ; **une règle « jamais » se pose en deny rule**, pas en absence d'allow — gabarit
  `deny: ["Bash(git commit *)", "Bash(git push *)"]` avec la limite `git -C . push` ; `/permissions`,
  `/fewer-permission-prompts`, `/sandbox` (Bash seulement) ; sans surveillance : `--permission-mode
  dontAsk` + `--allowedTools`, `permissions.denyInsteadOfPrompting` (v2.1.319+, user/managed).
- `rules/parallel-work.md` (pratique 8) — worktrees (`claude -w`, `.worktreeinclude`, nettoyage
  manuel après `-p --worktree`), `/batch`, boucle `claude -p` (gabarit officiel adapté, **2-3
  fichiers d'abord**, `--max-turns`, `--output-format json` pour la CI, `--bare`), les 5 questions
  avant un run sans surveillance ; commit autorisé seulement sur branche/worktree dédiée, merge par
  un humain. Code Mode : une ligne, marqué expérimental (v2.1.323+).
- `prompts/spec-interview.md` (pratique 2) — prompt d'interview (`AskUserQuestion`, une question à
  la fois) qui produit un `SPEC.md` autonome : objectif, fichiers touchés, interfaces, cas limites,
  hors périmètre, vérification de bout en bout (commande pass/fail) ; puis consigne d'implémenter
  dans une nouvelle session.
- `agents/plan-compliance-reviewer.md` (pratique 6) — agent **générique** (pas un gabarit),
  `tools: Read, Grep, Glob, Bash` (Bash pour `git diff` seulement, lecture), compare le diff à
  `plan.md`/`SPEC.md` : exigence non implémentée, cas limite sans test, fichier hors plan (dérive de
  scope) ; **ignore le style** et ne remonte que ce qui affecte la correction ou les exigences ;
  « rien à signaler » est une sortie valide. Mentionne le pattern Writer/Reviewer à deux sessions.

### Fichiers enrichis

- `rules/context-efficiency.md` — (5) section « Sous-agents » réécrite sur le critère du **volume**
  (formulation de réconciliation de `analyse.md`) ; (3) section « Mémoire et documentation projet » :
  test officiel « trouvable dans le code ? irait-il voir ? », ~200 lignes, `/doctor`
  (+ `prompt-audit` v2.1.283+), `/context all`, procédure → skill, pas d'emphase (règle sans
  exception → hook/deny) ; (10) nouvelle section courte « Ce que le modèle voit » : déterministe
  (hooks, deny, managed) vs indicatif (prompt, CLAUDE.md, skills), contexte pollué par des
  tentatives ratées → `/clear`, outils MCP inutiles → désactiver ; intro recadrée « coût et qualité »
  plutôt que « ressource finie » ; « Découpage de session » remplacée par un lien vers
  `session-management.md`.
- `rules/hooks.md` — gabarit « `Stop` qui bloque tant que le check échoue » (`<check> 1>&2 || exit
  2`, stderr renvoyé à Claude, plafond de 8 blocages, `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`,
  `stop_hook_active`) ; `/goal` comme équivalent limité à la session ; types `prompt`/`agent`
  (agent : expérimental) ; `SessionStart` matcher `compact` pour ré-injecter du contexte.
- `rules/mcp.md` — CLI d'abord quand elle existe (`gh`, `glab`, CLI du tracker ; `--help` suffit) ;
  MCP pour un système **sans** CLI ; coût en contexte des serveurs connectés, `/mcp` pour désactiver ;
  l'idée « forge Git sans repasser par `gh` » reformulée (redondante si `gh`/`glab` est installé).
- `rules/general-coding.md:28-29` — une phrase : la règle « pas de commit » s'applique par deny rule
  (lien `permissions.md`), et lien vers `verification.md` depuis la section « Revue ».
- `skills/start-ticket/SKILL.md` —
  - étape 3 : le plan contient la **commande de vérification** (pass/fail) qui dira que
    l'implémentation est finie ;
  - étape 4 : après validation, proposer de démarrer l'implémentation dans une **session vierge**
    (`/clear`, ou l'option « approuver et vider le contexte » du plan mode) — le plan sert de relais ;
  - étape 5 : l'implémentation n'est « finie » que quand cette commande passe, sortie montrée ;
  - étape 6 : nuance du « ne pas lancer les tests » (voir D1) ;
  - étape 7 : avant le message de commit, revue du diff contre `plan.md` par
    `plan-compliance-reviewer` (ou `/code-review`), écarts corrigés ou signalés.
- `skills/start-ticket/assets/plan-template.md` — section `## Vérification` (commande + résultat
  attendu).
- `prompts/README.md` — une ligne d'index pour `spec-interview.md`.
- `README.md` — tableau Inventaire uniquement : 4 lignes Rules, 1 ligne Prompts, 1 ligne Agents.
  Rien d'autre.

### Config du repo (D5 validé)

- `CLAUDE.md` (point 4 du workflow) — Claude affiche le message de commit (sans mention de Claude)
  puis demande la permission ; garanti par les règles ci-dessous.
- `.claude/settings.json` — `permissions.ask: [Bash(git commit *)]`,
  `permissions.deny: [Bash(git push *), Bash(gh pr merge *)]`.

## Cas limites

- Hook `PreToolUse` banwords : tout le contenu reste générique (`<check>`, `<nom>`) ; aucun nom de
  projet réel.
- Hook `Stop` `check-inventory.py` : les 6 nouveaux fichiers sous `rules/`, `prompts/`, `agents/`
  doivent apparaître dans le README avant la fin du tour qui les crée.
- Doc qui bouge vite : chaque version minimale citée provient de la doc lue le 2026-11-26 ; écrire
  « vérifié le 2026-11-26 » une fois par fichier concerné plutôt qu'à chaque ligne.
- Issue #24 (découpage de `start-ticket`) : les ajouts aux étapes 3-7 devront suivre dans les 3
  skills ; issues #10/#11/#12 : voir D2/D3.

## Vérification (fin d'implémentation)

1. `git status --short` : uniquement les fichiers listés ci-dessus.
2. Liens internes : script ponctuel (scratchpad) qui extrait chaque lien Markdown relatif des
   fichiers modifiés et teste `test -e` — 0 lien cassé.
3. Hooks : `check-inventory.py` lancé à la main (JSON `{}` sur stdin) → exit 0 ; aucune écriture
   bloquée par `block-banwords.py` pendant la session.
4. Revue du diff contre ce `plan.md` par un sous-agent en lecture seule (écarts de correction et
   d'exigences uniquement), puis message de commit via `writing-good-commits`.

## Décisions (validées le 2026-11-26)

Réponses : D1 → tests ciblés uniquement, en arrière-plan ; D2, D3, D6 → ok ; D4 → explication
demandée, en attente (pour l'instant : mécanismes documentés seulement, taxonomie non incluse) ;
D5 → ok, commit sans mention de Claude, message affiché puis permission demandée (`ask`, pas
`deny`, sur `git commit`).


- **D1 — contradiction `start-ticket` étape 6** (« ne pas lancer les tests » vs check pass/fail comme
  critère de fin). Proposé : l'étape 5 se termine par la commande de vérification **déjà existante**
  du projet (build/lint/tests existants ciblés), sortie montrée ; l'étape 6 STOP reste, mais ne
  porte plus que sur l'écriture de nouveaux tests et la doc. — `skills/start-ticket/SKILL.md`.
- **D2 — `plan-compliance-reviewer` vs issue #10 (`review-ticket`)**. Proposé : créer l'agent
  maintenant (relecteur seul, sans orchestration) ; #10 garde le skill qui l'appelle (verdict par
  critère, réutilisation des résultats de tests) — à noter dans #10, pas fermé.
- **D3 — `rules/verification.md` vs issue #11 (Definition of Done)**. Proposé : `verification.md` =
  *comment* rendre le travail vérifiable ; la DoD (#11) reste la checklist de clôture et y renverra.
- **D4 — taxonomie poisoning/distraction/confusion/clash** (non officielle). Proposé : ne pas
  l'inclure ; s'en tenir aux mécanismes documentés (pratique 10 ci-dessus). Alternative : 4 lignes
  avec la source externe citée.
- **D5 — `CLAUDE.md:87-89`** décrit une protection (permission absente de `settings.local.json`)
  qui n'existe pas sur ce poste et ne tiendrait pas en auto mode. Proposé : corriger la phrase et
  ajouter `deny: ["Bash(git commit *)", "Bash(git push *)", "Bash(gh pr merge *)"]` dans
  `.claude/settings.json` (versionné). Touche ta config : uniquement sur ton accord explicite.
- **D6 — découpage 7/8 en deux rules** (`permissions.md`, `parallel-work.md`) plutôt qu'une seule
  « autonomie ». Proposé : deux fichiers, sujets lus à des moments différents.

Documentation de ces décisions : aucune entrée `meta/docs/decisions/` proposée — ce sont des choix de
rangement internes à ce ticket, ce `plan.md` suffit comme trace.

## Revue du diff (sous-agent, contexte vierge)

Écarts remontés puis corrigés : `ask` sur `git commit` vérifié dans la doc (demande toujours en
auto mode, refusée en `dontAsk`) et ajouté à `rules/permissions.md` ; étape 5 de `start-ticket`
limitée aux tests existants ; Writer/Reviewer mentionné dans `plan-compliance-reviewer` ; date de
vérification ajoutée dans `context-efficiency.md`. Seuils auto mode (3/20) et table de compaction :
sourcés (`best-practices`, `context-window`). Ajouts hors plan acceptés (conséquences de D1).
