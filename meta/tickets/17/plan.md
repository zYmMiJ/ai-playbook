Statut : implémenté

## Objectif de l'US

Restructurer `README.md` et l'arborescence du repo selon deux axes (voir `analyse.md` pour le
détail des constats et options comparées) :

1. **Claude Code vs Codex** : séparer le narratif conceptuel ("AI tools") de la doc opérationnelle
   de setup Codex (extraite dans un fichier dédié), et étiqueter chaque dossier par IA propriétaire.
2. **Contenu du playbook vs fonctionnement interne de ce repo** (périmètre étendu en session, à la
   demande de l'utilisateur) : regrouper `tickets/`, `docs/`, `automation/` sous un dossier `meta/`
   pour qu'ils ne soient plus confondus avec le contenu à copier (`agents/`, `skills/`, `prompts/`,
   `rules/`, `templates/`).
3. **Pitch (README) vs mode opératoire (`CLAUDE.md`)** (2e extension de périmètre) : créer
   `CLAUDE.md` — symétrique à `AGENTS.md` pour Codex — et y déplacer tout ce qui est instruction
   d'exécution plutôt que présentation du repo. Voir `analyse.md`, section "Extension #2".

## Changements fichier par fichier

- **Déplacements (`git mv`, contenu inchangé)** :
  - `tickets/` → `meta/tickets/` (donc `tickets/15/` → `meta/tickets/15/`, et ce ticket lui-même :
    `tickets/17/` → `meta/tickets/17/`, déplacé en dernier).
  - `docs/` → `meta/docs/`.
  - `automation/` → `meta/automation/`.
- **`README.md`** :
  - `## Structure` : remplacer l'arbre ASCII par la version à jour, avec `meta/` regroupant
    `automation/`/`docs/`/`tickets/`, `.github/`/`.claude/`/`AGENTS.md` en bas (contrainte outil,
    ne bougent pas), et un commentaire inline par ligne précisant l'IA propriétaire — voir arbre
    final dans `analyse.md`.
  - `## AI tools` : raccourcir la sous-section "OpenAI Codex" — garder qui fait quoi + lien vers
    `AGENTS.md` (responsabilités) + lien vers le nouveau `meta/automation/release-notes/README.md`
    (setup). Supprimer le détail opérationnel désormais dans ce nouveau fichier. Mettre à jour le
    lien vers `tickets/15/` → `meta/tickets/15/`.
  - Supprimer entièrement la section `## OpenAI Codex setup` (~63 lignes) — contenu déplacé.
  - `## Workflow actuel` : mettre à jour les mentions `tickets/<ID>/...` → `meta/tickets/<ID>/...`
    et `docs/decisions/` → `meta/docs/decisions/` (ce sont des mentions décrivant le fonctionnement
    de *ce* repo, pas la convention générique des skills — voir `analyse.md`).
  - `## Inventaire` : mettre à jour le chemin de la ligne "Automation"
    (`automation/release-notes/prompt.md` → `meta/automation/release-notes/prompt.md`).
- **`AGENTS.md`** : mettre à jour les 2 mentions `automation/release-notes/` →
  `meta/automation/release-notes/`.
- **`.github/workflows/codex-release-notes.yml`** : mettre à jour le chemin lu par le step
  d'assemblage du prompt (`automation/release-notes/prompt.md` →
  `meta/automation/release-notes/prompt.md`).
- **`meta/automation/release-notes/README.md`** (nouveau) : contenu de l'actuelle section
  "OpenAI Codex setup" (création clé/projet OpenAI, secret GitHub, déclenchement du workflow avec
  exemple, coûts, retrait de l'intégration) — adapté en doc autonome (titre propre, pas de niveau de
  heading hérité du README).
- **`tickets/15/*` (historique déjà clos)** : **non modifié** — décision explicite, voir
  `analyse.md` (section "Vérification non-régression") : un ticket clos reste un compte-rendu figé,
  pas une doc vivante à resynchroniser après coup.
- **`CLAUDE.md`** (nouveau, racine) : reçoit `## Écrire dans ce repo` (intégral), `## Comment ce
  repo est versionné` (intégral), `## Workflow actuel : traiter un ticket de bout en bout`
  (intégral), et le détail par dossier de `## Comment utiliser ce repo` (checklist `> À adapter par
  projet`) — voir répartition détaillée dans `analyse.md`, section "Extension #2". Intro courte
  expliquant le rôle du fichier (symétrique à `AGENTS.md`).
- **`README.md`** (suite) : retirer les 4 sections listées ci-dessus une fois copiées dans
  `CLAUDE.md` ; remplacer `## Comment utiliser ce repo` par un résumé de quelques lignes (le
  principe : copier tel dossier, l'adapter) + lien vers `CLAUDE.md` pour le détail.

Le tableau "Inventaire" n'a qu'un changement de chemin (voir ci-dessus), pas de doublon.

## Cas limites

- **Lien externe déjà partagé vers l'ancre `#openai-codex-setup`** du README (peu probable, repo
  récent, mais pas vérifiable à 100 %) — accepté : pas de redirection possible sur un fichier
  Markdown statique, la section a un remplaçant clair (`meta/automation/release-notes/README.md`)
  plutôt qu'une suppression sèche.
- **Lien externe déjà partagé vers `tickets/15/` ou `docs/releases/`** (même remarque) — accepté,
  même raison ; ce sont des chemins internes à un repo récent, risque jugé faible.
- **`.github/workflows/codex-release-notes.yml` référence un chemin déplacé** — traité explicitement
  ci-dessus (chemin `meta/automation/release-notes/prompt.md` mis à jour dans le workflow lui-même).

## Décisions

- **Emplacement du fichier de setup extrait : `meta/automation/release-notes/README.md`** (pas
  `docs/tools/`) — proposé pour : rester tel quel, argumenté dans `analyse.md` (comparaison avec
  l'option `docs/tools/`) ; pas de doc `docs/decisions/` séparée pour ce choix — le repo applique
  déjà cette convention (`docs/releases/README.md`) sans qu'elle ait eu besoin d'être actée
  formellement.
- **Regroupement `tickets/`/`docs/`/`automation/` sous `meta/`** (au lieu d'isoler seulement
  `tickets/`, ou de ne rien déplacer) — validé par l'utilisateur (voir `analyse.md`, section
  "Extension du périmètre") ; proposé pour : rester tel quel, l'analyse du ticket fait déjà trace de
  la comparaison des options.
- **Pas de renommage `automation/` → `codex/`** malgré la demande de frontière Claude/Codex claire
  — proposé pour : rester tel quel, argumenté dans `analyse.md` ; frontière rendue lisible par
  commentaire inline dans `## Structure` plutôt que par un nom de dossier lié à un outil précis
  (le repo reste ouvert à un futur 2e moteur d'automatisation sans nouveau renommage).
- **Pas de regroupement/renommage de `.github/`/`AGENTS.md`/`.claude/`** (restent à la racine) —
  proposé pour : rester tel quel, contrainte d'outil (GitHub Actions, Codex, Claude Code cherchent
  ces chemins précis à la racine), argumenté dans `analyse.md`.
- **`tickets/15/` non retouché** (historique clos) — proposé pour : rester tel quel, principe
  documenté dans `analyse.md` ("un ticket clos est un compte-rendu figé").
- **Section "AI tools" reste à sa position actuelle** dans le README (avant "Workflow actuel"),
  seul son contenu est raccourci — proposé pour : rester tel quel (décision d'organisation mineure
  déjà tracée dans `analyse.md`).
- **Créer `CLAUDE.md` plutôt que de garder ces sections dans le README** — validé par l'utilisateur ;
  proposé pour : rester tel quel, argumenté dans `analyse.md` (symétrie avec `AGENTS.md`,
  répartition pitch/mode opératoire).
- **`## Comment utiliser ce repo` : résumé dans le README + détail dans `CLAUDE.md`** (pas tout
  déplacé, pas dupliqué) — proposé pour : rester tel quel, argumenté dans `analyse.md` (cas limite
  identifié : un lecteur GitHub sans Claude Code doit garder un minimum d'info utilisable).

## Fichiers prévus

- `README.md` (modifié)
- `CLAUDE.md` (nouveau, racine)
- `AGENTS.md` (modifié)
- `.github/workflows/codex-release-notes.yml` (modifié)
- `meta/automation/release-notes/README.md` (nouveau)
- `meta/tickets/17/analyse.md`, `meta/tickets/17/plan.md` (ce ticket, déplacé en fin d'implémentation)
- Déplacés sans modification de contenu : `meta/tickets/15/`, `meta/docs/`,
  `meta/automation/release-notes/prompt.md`

## Étapes

1. Créer l'US — [issue #17](https://github.com/zYmMiJ/ai-playbook/issues/17) +
   `tickets/17/analyse.md`/`plan.md` — fait.
2. Validation du plan par l'utilisateur — fait (extension de périmètre validée en session, puis
   "lance l'implémentation").
3. `git mv tickets meta/tickets`, `git mv docs meta/docs`, `git mv automation meta/automation`.
4. Écrire `meta/automation/release-notes/README.md`.
5. Mettre à jour `README.md` (arbre + AI tools + suppression setup Codex + chemins `meta/*`) —
   fait.
6. Mettre à jour `AGENTS.md` et `.github/workflows/codex-release-notes.yml` (chemins `meta/*`) —
   fait.
7. 2e extension validée par l'utilisateur ("go créé un claude.md...") : créer `CLAUDE.md`, y
   déplacer les 4 sections listées ci-dessus, trimmer le README en conséquence.
8. Vérifier les liens internes et la Definition of Done ci-dessous.
9. Proposer un message de commit référençant #17.

## Definition of Done

- [x] `## Structure` du README reflète l'arborescence réelle, avec `meta/` regroupant
      `automation/`/`docs/`/`tickets/` et un commentaire IA propriétaire par ligne.
- [x] `## OpenAI Codex setup` n'existe plus dans `README.md`, son contenu est intact dans
      `meta/automation/release-notes/README.md`.
- [x] `## AI tools` reste conceptuelle (qui fait quoi), sans le détail pas-à-pas du setup.
- [x] `AGENTS.md` et `.github/workflows/codex-release-notes.yml` pointent vers
      `meta/automation/release-notes/prompt.md`.
- [x] Tableau "Inventaire" toujours cohérent avec `check-inventory.py` (aucun chemin
      `skills/`/`agents/`/`rules/`/`prompts/` manquant — ces dossiers ne bougent pas).
- [x] `git status` ne montre plus `tickets/`, `docs/`, `automation/` à la racine (tout sous `meta/`).
- [x] `CLAUDE.md` existe, contient les 4 sections déplacées, `README.md` ne les contient plus (sauf
      résumé + lien pour "Comment utiliser ce repo").
- [x] Aucun lien interne cassé (README ↔ `CLAUDE.md` ↔ `AGENTS.md` ↔ `meta/tickets/15/` ↔ nouveau
      fichier de setup Codex).
