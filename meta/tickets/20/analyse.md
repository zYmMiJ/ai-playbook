Reconstruit depuis le code déjà écrit et la discussion de session — à recouper avec le ticket réel
([issue #20](https://github.com/zYmMiJ/ai-playbook/issues/20)) dès qu'accessible.

## Contexte

[#15](https://github.com/zYmMiJ/ai-playbook/issues/15) a introduit un workflow GitHub Actions
(`codex-release-notes.yml`) qui appelle `openai/codex-action@v1` pour générer un brouillon de
release notes à partir de l'historique Git, en lecture seule. Implémenté, testé (clé API
configurée par l'utilisateur), fonctionnel.

En configurant la clé, l'utilisateur relève un point que l'analyse initiale n'avait pas assez pesé :
générer ces release notes ne demande aucune capacité créative d'un LLM. Le prompt donné à Codex
(`meta/automation/release-notes/prompt.md`) est déjà une spec 100% déterministe :

- grouper par préfixe conventionnel (`feat` → Fonctionnalités, `fix` → Corrections, `docs` →
  Documentation, reste → Autres) ;
- détecter un breaking change uniquement sur un marqueur explicite (`!` après le type/scope, ou
  footer `BREAKING CHANGE:`) — jamais par inférence ;
- lister un commit non conventionnel tel quel plutôt que de deviner sa catégorie.

Ce sont des règles de parsing, pas de génération. Le repo respecte déjà cette convention (voir
`writing-good-commits`) et structure ses plages de tags via Git Flow (`release`/`hotfix`, voir
`git-flow.md`) — les deux prérequis pour qu'un script fasse exactement le même travail que Codex,
sans risque d'hallucination (un LLM peut dévier du prompt) et sans coût API.

Le mécanisme humain existant, `generate-release-note` (skill Claude Code, usage interactif après
validation d'une release), fait déjà ce travail manuellement avec la même logique de catégorisation
— ce ticket porte la même logique côté CI, en script plutôt qu'en skill.

## Problème

Le workflow `codex-release-notes.yml` consomme du crédit OpenAI (facturation à l'usage, cf.
`meta/tickets/15/`) pour une tâche entièrement mécanique. Ce n'est pas un problème de fiabilité
(le prompt contraint déjà bien Codex) mais un problème de coût et de dépendance externe injustifiés
pour ce cas d'usage précis.

## Options considérées

1. **Garder Codex tel quel** — rejeté : aucun bénéfice constaté (le prompt est déjà déterministe)
   pour un coût et une dépendance (clé API, disponibilité du service OpenAI) non nuls.
2. **Remplacer par un script déterministe, retirer toute la plomberie Codex du repo** — rejeté pour
   l'instant : décision utilisateur explicite de garder `AGENTS.md`/le secret/l'action en place pour
   un futur cas d'usage Codex non encore identifié — un aller-retour de configuration (clé/projet
   OpenAI, secret GitHub) coûte plus cher en friction que de laisser la plomberie inactive.
3. **Remplacer uniquement ce workflow par un script déterministe, garder la plomberie Codex pour
   plus tard** — retenu. Isole le changement au seul cas d'usage concerné ; `AGENTS.md` documente
   que Codex n'a provisoirement plus de responsabilité active.

## Architecture retenue

- Script `meta/automation/release-notes/generate.sh` — transcrit les règles de
  `meta/automation/release-notes/prompt.md` en `bash`/`git log --pretty` + `grep`/`case` sur le
  préfixe conventionnel. Un seul fichier, appelable aussi bien par le workflow que testable en
  local (`from_ref`/`to_ref` en arguments) — contrairement au prompt Codex qui n'existait que dans
  le contexte du workflow.
- Workflow renommé `codex-release-notes.yml` → `release-notes.yml` (le nom `codex-*` induirait en
  erreur maintenant que Codex n'y intervient plus) : mêmes inputs `workflow_dispatch`
  (`from_ref`/`to_ref`), mêmes steps de résolution de plage et de checkout, mais l'étape "Générer via
  Codex" est remplacée par un appel au script. Résultat toujours publié en artifact
  (`actions/upload-artifact`), jamais écrit dans `meta/docs/releases/` — même limite de périmètre
  que la version Codex, pas de changement de ce côté.
- `meta/automation/release-notes/prompt.md` supprimé (règles maintenant encodées directement dans
  le script, pas de prompt à maintenir en double).
- `AGENTS.md` : la section "Codex responsibilities" perd son unique entrée (release notes) ; note
  explicite que Codex n'a provisoirement plus de workflow actif, plomberie conservée pour plus tard.
- Doc setup Codex (création clé/projet OpenAI, secret GitHub, sécurité, rotation — déjà écrite dans
  `meta/automation/release-notes/README.md` pour #15) déplacée vers `meta/automation/README.md`,
  décorrélée de release-notes puisqu'elle ne documente plus un besoin actif de ce dossier
  spécifique mais reste utile pour la prochaine automatisation Codex. `meta/automation/release-notes/README.md`
  réécrit pour documenter uniquement le nouveau mécanisme (déclenchement, pas de secret requis).

## Cas limites

Repris tels quels de #15 (le script doit se comporter pareil que le prompt Codex sur ces points) :

- `from_ref` non fourni et aucun tag précédent trouvable avant `to_ref` → le workflow échoue
  explicitement (`::error::` + `exit 1`), logique déjà dans l'étape "Déterminer la plage de
  commits", non touchée par ce ticket.
- Plage vide (aucun commit non-merge) → le script doit produire un résultat qui l'indique
  explicitement ("Aucun changement dans cette plage."), jamais un fichier vide silencieux ni un
  contenu inventé.
- Commit sans préfixe conventionnel reconnu → listé tel quel sous "Autres", jamais reclassé à la
  devinette (même règle que le prompt Codex, portée dans le script plutôt que dans un prompt).
- Breaking change → uniquement sur marqueur explicite (`!` avant les deux-points du header, ou
  ligne `BREAKING CHANGE:` dans le corps du commit) — un script peut détecter ça de façon fiable par
  regex, contrairement à une inférence de sens qu'on demandait à Codex de ne *pas* faire.

## Décision

Retenu : script déterministe remplaçant Codex pour ce seul workflow, plomberie Codex générale
conservée pour un futur cas d'usage (décision utilisateur explicite, voir Options ci-dessus).
