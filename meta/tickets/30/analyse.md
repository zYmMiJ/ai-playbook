Ticket reconstruit depuis la demande en session, issue créée ensuite :
[issue #30](https://github.com/zYmMiJ/ai-playbook/issues/30).

## Contexte

Mettre le playbook à jour avec les pratiques Claude Code / agentic coding de fin 2026 (10 pratiques
listées dans la demande). Chaque fonctionnalité citée a été vérifiée dans la doc officielle le
2026-11-26 (pages `.md` brutes de `code.claude.com/docs/en/…`) : `best-practices`, `goal`, `hooks`,
`checkpointing`, `permission-modes`, `permissions`, `settings`, `sandboxing`, `sub-agents`,
`common-workflows`, `commands`, `cli-reference`, `memory`, `context-window`, `code-mode`,
`code-review-local`, `skills`, `tools-reference`.

Légende : ✅ déjà couvert · 🟡 partiel · ⚠️ en contradiction · ❌ absent · 📘 vérifié dans la doc ·
❓ introuvable / non officiel / expérimental.

## Écarts entre la demande et la doc officielle (à arbitrer)

| Point de la demande | Ce que dit la doc | Proposition |
|---|---|---|
| « Un seul IMPORTANT à la fois » (pratique 3) | ❓ Pas dans la doc. Elle dit l'inverse : « adding IMPORTANT probably won't fix it » ; l'emphase est classée en *old advice* (« piling on emphasis mostly makes Claude over-apply the rule ») — une règle sans exception va dans un hook ou une deny rule (`best-practices`). | Écrire « pas d'emphase ; règle sans exception → hook/deny », pas « un seul IMPORTANT ». |
| Test « l'enlever ferait-il faire une erreur ? » (3) | ❓ Formulation absente. Test officiel : « Could it find this by reading the code? Would it actually go and look? If both are yes, leave it out. » + rester sous ~200 lignes. | Citer le test officiel, garder l'autre comme reformulation. |
| « Consignes de compaction dans CLAUDE.md » (3) | ❓ Pas de section dédiée dans la doc. Ce qui existe : le `CLAUDE.md` racine est ré-injecté depuis le disque après compaction (`memory`, `context-window`) ; une consigne donnée seulement en conversation se perd ; `/compact <focus>` ; hook `SessionStart` matcher `compact` pour ré-injecter du contexte. | Documenter le mécanisme réel (ce qui survit, comment le forcer), pas une « section compaction » inventée. |
| Explorer → planifier → coder → committer, « sauter le plan si le diff tient en une phrase » (2) | 🟡 Le plan mode est documenté (`permission-modes`, `common-workflows` : « Plan before editing »), `Ctrl+G` aussi (`permission-modes`). La séquence nommée en 4 temps et le critère « une phrase » ne sont **plus** sur la page best-practices actuelle. | Garder la séquence comme pratique du repo, sans l'attribuer à la doc. |
| `AskUserQuestion` pour l'interview (2) | 📘 Outil réel (`tools-reference`). La doc best-practices décrit le pattern (« Interview me until you could write the spec, then write it to SPEC.md », puis « start a fresh session to build from it ») sans nommer l'outil. | OK. |
| Sous-agents « pour garder le contexte principal propre » (5) | ⚠️ Doc ambivalente : `common-workflows`/`sub-agents` disent encore « Delegate the exploration so only the findings come back » ; mais `best-practices` classe « Use subagents to protect your context window » en *old advice* (fenêtre 1M, compaction auto) et précise que les recherches larges partent **déjà** d'elles-mêmes dans l'agent Explore. Coût réel : tokens, parfois du temps. | Voir réconciliation ci-dessous (pratique 5). |
| Context poisoning / distraction / confusion / clash (10) | ❓ Absent de la doc officielle. Taxonomie d'origine externe (billet « How Long Contexts Fail », 2025). La doc couvre l'idée voisine : contexte qui accumule des tentatives ratées (`/clear` après 2 corrections), serveurs MCP inutiles qui chargent du contexte, contenu chargé par défaut (`context-window`). | À arbitrer : l'inclure avec source externe explicite, ou s'en tenir aux mécanismes documentés. |
| Code Mode (8) | ❓ Existe mais **expérimental, désactivé par défaut**, « may change or be removed in any release » ; v2.1.323+, `CLAUDE_CODE_EXPERIMENTAL_CODE_MODE=1` (`code-mode`). | Une mention signalée expérimentale au plus, pas une pratique recommandée. |
| `/goal` (1) | 📘 Existe (`goal`, `commands`) ; une seule goal par session ; check-ins v2.1.234+. | OK. |
| `permissions.denyInsteadOfPrompting` (7) | 📘 Existe, v2.1.319+, honoré **dans les settings utilisateur/managed ou `--settings`** uniquement (`settings`, `permissions`). | OK, avec la contrainte de scope. |
| Auto mode « comme mode par défaut » (7) | 📘 Mode de départ intégré des sessions interactives depuis v2.1.283 ; ⚠️ `auto` **ne prend pas effet depuis `.claude/settings.json` / `settings.local.json`** du projet (settings utilisateur/managed ou `--permission-mode` seulement). Le classifieur « does not guarantee safety ». | Voir pratique 7. |

## État du repo, pratique par pratique

### 1. Vérification exécutable — 🟡 partiel, ⚠️ une contradiction

- ✅ `rules/general-coding.md:26-27` (critère de succès vérifiable avant un refactor),
  `prompts/refactor-review.md:7-9`, `rules/general-coding.md:50-57` (lint/test qui passe ≠ sans
  défaut, dire ce qui n'a pas été vérifié).
- 🟡 `rules/hooks.md:16` cite `Stop` « pour une vérification de fin de tâche » sans le mécanisme
  (exit 2 + stderr renvoyé à Claude, plafond de 8 blocages, `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`) ; le
  hook en place `.claude/hooks/check-inventory.py` est un vrai exemple de Stop bloquant.
- ❌ Échelle prompt → `/goal` → hook `Stop` → relecteur en contexte vierge (`/code-review`), exigence
  de preuve (commande + sortie), `/verify` (📘 skill intégré `skills#run-and-verify-your-app`).
- ⚠️ `skills/start-ticket/SKILL.md:78-82` (étape 6) : « **Ne pas lancer les tests** » tant que
  l'implémentation n'est pas confirmée — à l'opposé de « donner un check pass/fail comme critère de
  fin ». Contradiction à trancher par l'utilisateur.
- Recouvrement avec l'issue ouverte **#11** (rule Definition of Done) et **#12**
  (targeted-test-runner).

### 2. Explorer → planifier → coder → committer — 🟡 partiel

- ✅ Séparation analyse / plan / validation / implémentation : `skills/start-ticket/SKILL.md:44-75` ;
  prompt `prompts/refactor-review.md`.
- ❌ Plan mode (`Shift+Tab`, `claude --permission-mode plan`), `Ctrl+G` pour éditer le plan
  (📘 `permission-modes`), option « approuver et vider le contexte »
  (`showClearContextOnPlanAccept`, 📘).
- ❌ Interview → `SPEC.md` autonome → nouvelle session (📘 `best-practices`). Pas de prompt dédié.
- ❌ Quand sauter le plan.

### 3. CLAUDE.md minimal — 🟡 partiel, ⚠️ sur l'emphase

- ✅ `rules/context-efficiency.md:75-78` (CLAUDE.md court, détail dans un fichier lié),
  `rules/agents-md.md:10-11` (« ne documenter que ce qui n'est pas déductible du code »),
  `rules/hooks.md:3-5` (hook = garanti, CLAUDE.md = indicatif).
- ❌ Test officiel « trouvable en lisant le code ? irait-il voir ? », ~200 lignes, `/doctor` (📘 propose
  des coupes) et `/doctor prompt-audit` (📘 v2.1.283+), `/context all` pour vérifier le chargement,
  procédure → skill (chargé à la demande), `disable-model-invocation: true` pour un skill à effet de
  bord, `.claude/rules/` avec `paths:`.
- ❌ Ce qui survit à la compaction (voir écarts).
- ⚠️ Ce repo lui-même : `CLAUDE.md` fait 108 lignes dont une bonne part de narratif (ex. `CLAUDE.md:91-96`,
  vécu de perte de code) — candidat à `/doctor`. **Hors périmètre** de ce ticket sauf demande.

### 4. Gestion de session — 🟡 partiel

- ✅ `/clear` entre phases d'un ticket : `rules/context-efficiency.md:50-57`,
  `skills/start-ticket/SKILL.md:23-28`.
- ❌ `/clear` après 2 corrections ratées, `Esc`, `/rewind` / `Esc Esc` (restaurer code/conversation/
  les deux, « Summarize from here / up to here »), checkpoints ≠ git (les modifs faites en Bash ne
  sont pas suivies), `/btw`, `/compact <focus>`, `/clear <nom>`, `/rename` + `claude --resume <nom>`,
  `claude -n` (tous 📘 `best-practices`, `checkpointing`, `commands`, `cli-reference`).

### 5. Sous-agents pour l'investigation — ⚠️ à réconcilier

- `rules/context-efficiency.md:31-41` : « ne pas déléguer ce qui peut se faire directement… un agent
  démarre à froid… réserver à parallélisation, isolation d'un travail volumineux/risqué, demande
  explicite ». Cohérent avec la doc sur le coût, mais muet sur le **volume lu** comme critère.
- `rules/context-efficiency.md:3-7` présente le contexte comme « ressource finie » — proche de
  l'*old advice* « the context window is your main constraint » ; la doc recadre en **coût et qualité**
  (chaque tour renvoie toute la conversation ; un contexte focalisé donne de meilleures réponses).
- Réconciliation proposée : *le critère est le volume que la tâche fera entrer dans le contexte
  principal et qui ne resservira pas, pas le coût de démarrage du sous-agent. Exploration large
  (beaucoup de fichiers lus pour une conclusion courte), suite de tests verbeuse, logs → sous-agent,
  avec demande d'un résumé court. Lecture ciblée de quelques fichiers qu'on va éditer ensuite →
  directement. Un sous-agent n'améliore pas la réponse ; seul un relecteur vierge apporte un regard
  neuf. Les recherches larges partent déjà d'elles-mêmes dans Explore : inutile de le demander.*
  📘 `best-practices` (« Know what subagents cost »), `sub-agents`, `common-workflows`.

### 6. Revue adversariale sans sur-ingénierie — 🟡 partiel

- ✅ Gabarits de relecteurs : `agents/local-changes-reviewer.md` (diff local,
  « si le diff est propre, dis-le plutôt que d'inventer des findings », l.89-90),
  `agents/security-reviewer.md`, `agents/api-contract-reviewer.md`.
- ❌ Revue **contre le plan/spec** limitée aux écarts de correction ou d'exigences, « skip style »
  (📘 `best-practices` : « A reviewer that's asked to find problems will always find *something* »),
  `tools: Read, Grep, Glob` appliqué par le harness ; `/code-review` (📘 sous-agent vierge) ;
  Writer/Reviewer en deux sessions (📘).
- Recouvrement direct avec l'issue ouverte **#10** (`review-ticket` : diff + critères d'acceptation
  du `plan.md`, verdict par critère, dérive de scope).

### 7. Permissions et autonomie — ❌ absent, ⚠️ risque sur la règle « Claude ne committe jamais »

- ✅ Règle : `rules/general-coding.md:28-29`, `CLAUDE.md:85-90`, `skills/start-ticket/SKILL.md:90-92`.
- ⚠️ `CLAUDE.md:87-89` fait reposer la règle sur l'**absence** de permission `git commit` dans
  `.claude/settings.local.json`. Or (a) ce fichier n'existe pas actuellement dans `.claude/` de ce
  poste, (b) en auto mode (défaut des sessions interactives depuis v2.1.283) une commande sans règle
  part au classifieur, qui peut l'approuver. Seule une **deny rule** tient dans tous les modes
  (📘 `permissions` : deny > ask > allow, « Deny rules block in every mode, including
  bypassPermissions »). Limite documentée : `Bash(git push *)` ne bloque pas `git -C . push`.
- ❌ Modes (`default`/`acceptEdits`/`plan`/`auto`/`dontAsk`/`bypassPermissions`), `/permissions`,
  `/fewer-permission-prompts`, `/sandbox` (Bash seulement, macOS/Linux/WSL2), `--permission-mode
  dontAsk` + `--allowedTools` pour un script, `permissions.denyInsteadOfPrompting` (v2.1.319+,
  user/managed).

### 8. Parallélisation — ❌ absent

- ✅ Indirect : `rules/general-coding.md:30-33` (traitement par lot : un seul élément d'abord) — même
  esprit que « tester sur 2-3 fichiers ».
- ❌ `claude -w <nom>` / `--worktree` (📘), `.worktreeinclude` (📘), `/batch` (📘, 5 à 30 unités, une
  worktree par unité ; hors dépôt git v2.1.281+), boucle `claude -p` + `--allowedTools` +
  `--permission-mode dontAsk` + `--max-turns` (📘 exemple officiel, « Try it on three files first »),
  `--output-format json|stream-json` (📘), `--bare` (📘). Code Mode : ❓ expérimental.
- ⚠️ La boucle officielle fait `… and commit` : contraire à la règle du repo pour une session
  interactive ; acceptable seulement pour une automatisation sur branche/worktree dédiée, revue
  humaine avant merge.

### 9. CLI plutôt que MCP — ⚠️ partiel

- `rules/mcp.md:10-16` présente déjà la CLI comme voie par défaut et MCP comme gain « avec la
  fréquence d'usage » ; mais `rules/mcp.md:40-41` propose un MCP forge Git « sans repasser par
  `gh`/`git` » — à l'inverse de la doc (📘 « If that system has a CLI, that's usually the easiest
  way in… For systems without a CLI, there's MCP » ; les serveurs connectés ajoutent leurs outils au
  contexte même inutilisés → les désactiver).

### 10. Context engineering / harness — 🟡 partiel

- ✅ Implicite partout dans `rules/context-efficiency.md` (lecture ciblée, exploration minimale) et
  `rules/hooks.md` (harness déterministe vs consigne).
- ❌ Distinction explicite déterministe (hooks, deny rules, managed settings) / non déterministe
  (prompt, CLAUDE.md, skills) — 📘 intro `best-practices`. Ce qui est chargé et ce qui survit à la
  compaction (📘 `context-window`). La taxonomie poisoning/distraction/confusion/clash : ❓ non
  officielle.

## Autres constats

- Le tableau Inventaire (`README.md`, lignes `hooks.md` et `mcp.md`) cite en « Source »
  `.claude/hooks/README.md` / `.claude/mcp/README.md`, qui n'existent pas — hors périmètre, signalé.
- Issue ouverte **#24** (découper `start-ticket` en 3 skills) : toute modification de `start-ticket`
  dans ce ticket devra être reportée dans ce découpage.
- Versions minimales relevées : auto mode par défaut v2.1.283 ; `denyInsteadOfPrompting` v2.1.319 ;
  `/doctor prompt-audit` v2.1.283 ; `/batch` hors git v2.1.281 ; `/goal` check-ins v2.1.234 ;
  Code Mode v2.1.323 ; `/code-review --max-findings` v2.1.288. Pas de version indiquée pour
  `/btw`, `/rewind`, `/sandbox`, `--worktree`, Stop hook.
