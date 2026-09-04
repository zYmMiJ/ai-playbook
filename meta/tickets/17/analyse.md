# Analyse — US #17 : restructurer le README

Ticket source : [issue #17](https://github.com/zYmMiJ/ai-playbook/issues/17), suite de l'US #15
(intégration Codex). Contenu de l'issue disponible directement via `gh issue view 17` — pas de
reconstruction nécessaire.

## Contexte

Le README (`README.md`, 246 lignes) a grossi de ~95 lignes d'un coup lors de l'US #15 : les
sections "AI tools" (lignes 58-90) et "OpenAI Codex setup" (91-153) ont été insérées **au milieu**
du narratif existant, entre "Comment ce repo est versionné" et "Workflow actuel : traiter un ticket
de bout en bout".

## Ordre actuel des sections (relevé sur le README présent)

1. Titre + intro
2. `## Structure` (arbre ASCII)
3. `## Comment utiliser ce repo`
4. `## Écrire dans ce repo`
5. `## Comment ce repo lui-même est versionné`
6. `## AI tools` ← inséré par l'US #15
7. `## OpenAI Codex setup` ← inséré par l'US #15, ~63 lignes, doc opérationnelle détaillée
8. `## Workflow actuel : traiter un ticket de bout en bout`
9. `## Inventaire`
10. `## Origine`
11. `## Statut`

Avant l'US #15, l'enchaînement 1→5→8→9→10→11 formait un narratif continu : pourquoi ce repo existe
→ comment s'en servir → comment il est versionné → comment un ticket y est traité → ce qu'il
contient → d'où ça vient → son statut. Les sections 6-7 cassent cet enchaînement : "OpenAI Codex
setup" en particulier (création de clé API, secret GitHub, procédure de test, coûts, retrait) est
une doc **opérationnelle pas-à-pas pour une personne qui active l'intégration**, pas un contenu que
quelqu'un lit pour comprendre comment travailler sur ce repo — un public et un moment de lecture
différents du reste du README.

## Pourquoi ce n'est pas seulement "trop long"

Le problème n'est pas la longueur en soi (le README fait déjà 246 lignes avec le tableau
Inventaire, personne ne s'en plaint) mais le **mélange de deux registres** dans la même page :
narratif conceptuel (pourquoi/comment) vs procédure opérationnelle d'un outil précis (setup pas à
pas). `rules/docs-structure.md` distingue déjà ce genre de registres pour la doc de projet
(architecture/decisions/modules) mais ne couvre pas explicitement un "guide de setup d'un outil
d'automatisation" — aucun des 3 dossiers (`architecture/`, `decisions/`, `modules/`) n'est un bon
fit : ce n'est ni une vue d'ensemble transverse, ni une décision à valider, ni une fiche
piège/règle d'un module de code.

## Emplacement retenu pour extraire "OpenAI Codex setup"

Option retenue : **`automation/release-notes/README.md`**, colocalisé avec `prompt.md` (déjà dans
ce dossier) plutôt qu'un nouveau dossier `docs/tools/` ou similaire.

Comparaison :
- **`docs/tools/codex-setup.md`** (nouveau dossier) — rejeté : `docs-structure.md` dit
  explicitement de n'ajouter un dossier que par besoin réel constaté, pas par symétrie ; un seul
  fichier ne justifie pas un 4e dossier `docs/` alors que le contenu est spécifique à *cette*
  automatisation précise, pas transverse au projet.
- **`automation/release-notes/README.md`** (retenu) — cohérent avec le pattern déjà présent dans ce
  repo (`docs/releases/README.md` comme index d'un dossier de contenu ; `templates/docs/*/README.md`
  comme doc d'un dossier). Le setup ne concerne que ce workflow précis ; le jour où une 2e
  automatisation Codex existe, elle aura son propre dossier sous `automation/` avec son propre
  README si besoin — pas de sur-anticipation ici.
- Le README garde un lien vers ce fichier depuis la section "AI tools" plutôt que de dupliquer le
  contenu.

## Contenu qui reste dans le README vs qui part

**Reste dans `## AI tools`** (conceptuel, trimmé) :
- Qui fait quoi (Claude Code = assistant interactif principal ; Codex = automatisation CI
  uniquement, jamais de session interactive).
- Les responsabilités actuelles de Codex (liste courte, déjà en grande partie dans `AGENTS.md` —
  éviter la duplication en renvoyant vers `AGENTS.md` plutôt que de recopier la liste).
- Un lien vers `automation/release-notes/README.md` pour qui veut réellement activer l'intégration.

**Part vers `automation/release-notes/README.md`** (opérationnel) :
- Création du projet/clé API OpenAI.
- Ajout du secret GitHub.
- Déclenchement du workflow (`workflow_dispatch`, inputs, exemple).
- Coûts.
- Comment retirer l'intégration.

Décision de position : la section "AI tools" (trimmée) **reste à sa place actuelle** (avant
"Workflow actuel"), plutôt que d'être déplacée ailleurs dans le README — son contenu (quel outil
IA fait quoi) est un contexte utile juste avant de détailler le workflow Claude Code qui suit,
et déplacer une section en plus du découpage augmenterait le diff/risque de casser des ancres sans
bénéfice clair. Seul son contenu change (nettement raccourci), pas sa position.

## Schéma ASCII de `## Structure` — écart constaté

Arbre actuel :
```
ai-playbook/
├── agents/      # agents Claude Code — copier le fichier dans .claude/agents/ d'un projet
├── skills/      # skills Claude Code — copier le dossier dans .claude/skills/ d'un projet
├── prompts/     # prompts type, à copier-coller
├── rules/       # conventions générales, à piocher pour amorcer un CLAUDE.md
└── templates/   # squelettes de fichiers/dossiers à copier tels quels
```

Répertoires top-level réels (relevé `find . -maxdepth 2`), hors dotdirs d'IDE (`.idea/`, `.junie/`)
et config d'outil (`.claude/` — déjà documenté dans "Écrire dans ce repo") :

- `agents/`, `skills/`, `prompts/`, `rules/`, `templates/` — déjà dans l'arbre, inchangés.
- `automation/` — absent, contient le prompt Codex (`automation/release-notes/prompt.md` +, après
  ce ticket, son `README.md` de setup).
- `.github/` — absent, contient `workflows/codex-release-notes.yml`.
- `AGENTS.md` — absent, fichier racine (instructions Codex).
- `docs/` — absent, contient `docs/releases/` (notes de release taguées) ; convention documentée
  dans `rules/docs-structure.md` mais le dossier lui-même n'apparaît jamais dans l'arbre du README.
- `tickets/` — absent, contient `tickets/<ID>/` (analyse + plan par US, dogfooding de
  `start-ticket`/`user-stories`).

Cette première proposition (tout à plat à la racine) a été remplacée par le découpage ci-dessous,
suite à une extension du périmètre demandée par l'utilisateur en cours d'analyse (voir section
suivante) : `automation/`, `docs/`, `tickets/` ne restent pas à plat, ils sont regroupés sous
`meta/`.

## Extension du périmètre : contenu du playbook vs fonctionnement interne (`meta/`)

Demande de l'utilisateur, en plus de la frontière Claude/Codex déjà traitée ci-dessus : séparer
plus largement ce qui est **le contenu du playbook** (ce que quelqu'un copie dans son propre
projet) de ce qui est **le fonctionnement opérationnel de ce repo lui-même** (dogfooding, jamais à
copier) — `tickets/15`, `tickets/17` cités comme exemple le plus visible (des numéros nus, sans
contexte dans l'arbre), mais pas le seul cas concerné.

**Répartition constatée** :

| Contenu du playbook (à copier) | Fonctionnement interne de ce repo (jamais à copier) |
|---|---|
| `agents/`, `skills/`, `prompts/`, `rules/`, `templates/` | `tickets/` (dogfooding `start-ticket`), `docs/` (releases propres à ce repo), `automation/` (prompt Codex de la CI de ce repo), `.github/`, `AGENTS.md`, `.claude/` |

**Contrainte** (déjà posée dans la section précédente) : `.github/` (chemin imposé par GitHub
Actions) et `AGENTS.md` (convention Codex, lu à la racine) ne peuvent pas bouger. `.claude/` a la
même contrainte (Claude Code cherche ce dossier précis à la racine du repo). Seuls `tickets/`,
`docs/`, `automation/` sont librement déplaçables — aucune contrainte d'outil dessus, seulement des
chemins que ce repo référence lui-même (`README.md`, `AGENTS.md`,
`.github/workflows/codex-release-notes.yml`).

**Vérification faite avant de trancher** : les mentions `tickets/<ID>/`, `docs/decisions/` etc.
dans `skills/start-ticket/`, `rules/docs-structure.md`, `skills/generate-release-note/`,
`skills/user-stories/` sont des **conventions génériques pour un projet qui copie le skill** — pas
des chemins vers ce repo. Les déplacer ici ne touche aucun de ces fichiers de contenu, seulement
les fichiers "vivants" qui décrivent le fonctionnement de ce repo précis (voir `plan.md`).

**Décision validée par l'utilisateur** : regrouper les 3 dossiers déplaçables sous un seul dossier
`meta/` plutôt que de n'isoler que `tickets/` (option écartée : `docs/` et `automation/` ont
exactement le même statut, les laisser à plat aurait été incohérent) ou de se contenter d'une
clarification README sans déplacement (option écartée : ne corrige pas ce qu'on voit en parcourant
l'arbre de fichiers bruts sur GitHub, seulement ce qui est écrit dans le README).

**Séparation Claude/Codex, appliquée à `meta/`** : l'utilisateur a reconfirmé vouloir cette
frontière lisible. Plutôt que renommer `automation/` en quelque chose comme `codex/` (rejeté : le
repo se veut ouvert à "d'autres outils IA plus tard" pour l'automatisation aussi, un nom générique
reste plus robuste qu'un nom d'outil qui devrait être re-renommé le jour où un 2e moteur
d'automatisation apparaît — cohérent avec la décision de la section précédente de ne pas renommer
par réflexe), la frontière est rendue explicite **par un commentaire inline par ligne** dans le
schéma `## Structure`, précisant l'IA propriétaire de chaque dossier :

```
ai-playbook/
├── agents/          # contenu à copier — Claude Code
├── prompts/         # contenu à copier — Claude Code
├── rules/           # contenu à copier — Claude Code
├── skills/          # contenu à copier — Claude Code
├── templates/       # contenu à copier — Claude Code
├── meta/            # fonctionnement interne de ce repo — jamais à copier
│   ├── automation/  #   Codex (CI uniquement) — voir AGENTS.md
│   ├── docs/         #   releases/décisions propres à ce repo
│   └── tickets/      #   dogfooding start-ticket (Claude Code)
├── .github/         # workflows CI — Codex (contrainte GitHub, reste à la racine)
├── .claude/         # hooks/config — Claude Code (contrainte outil, reste à la racine)
├── AGENTS.md        # instructions Codex (contrainte outil, reste à la racine)
└── README.md
```

Chaque ligne porte maintenant deux informations à la fois : contenu vs méta (regroupement physique
sous `meta/`) et Claude vs Codex (commentaire inline) — sans renommage qui figerait un choix
d'outil dans un nom de dossier.

## Regroupement/renommage des fichiers Codex — évaluation (frontière Claude/Codex seule, avant l'extension ci-dessus)

L'issue demande de trancher explicitement plutôt que par réflexe. Constat :
- Les 3 éléments Codex (`automation/`, `.github/workflows/`, `AGENTS.md`) sont déjà à des
  emplacements strictement imposés par l'écosystème GitHub Actions/Codex lui-même
  (`.github/workflows/` est un chemin fonctionnel obligatoire, `AGENTS.md` est un nom de fichier
  reconnu par convention Codex à la racine) — il n'y a rien à "regrouper" sans casser le
  fonctionnement de l'un des deux (workflow GitHub, découverte d'`AGENTS.md` par Codex).
- Seul `automation/` est un choix de nommage libre ; il est déjà nommé par fonction
  (`release-notes/`) et déjà distinct de `skills/`/`agents/` (les dossiers Claude Code).
- **Décision : pas de déplacement/renommage.** La frontière Claude/Codex est déjà lisible dans
  l'arborescence une fois que `## Structure` est à jour (fichiers Codex identifiables par leur
  emplacement et leur commentaire inline) + `AGENTS.md` qui explicite la frontière en toutes
  lettres. Un renommage forcerait en plus à casser les chemins imposés (`.github/workflows/`) sans
  gain — pas justifié.

## Impact sur le tableau "Inventaire"

Aucun changement structurel : la ligne `automation/release-notes` (table "Automation") reste,
seul son chemin change (`meta/automation/release-notes/prompt.md`). Elle ne référence pas la
section "OpenAI Codex setup" du README — pas de doublon créé. Le hook `check-inventory.py` ne
surveille que `skills/`, `agents/`, `rules/`, `prompts/` (`TRACKED` dans le script) — `automation/`
(ni `meta/automation/`) n'y est inclus, donc ce déplacement n'a aucun impact sur ce hook.

## Vérification non-régression

- **`check-inventory.py`** : chemins `skills/*/SKILL.md`, `agents/*.md`, `rules/*.md`,
  `prompts/*.md` restent tous présents tels quels dans le README, à un niveau inchangé (pas sous
  `meta/`) — pas de risque.
- **Liens internes à mettre à jour** (chemins qui changent avec le déplacement `tickets/` /
  `docs/` / `automation/` → `meta/*`) :
  - `README.md` : lien vers `tickets/15/` (section "AI tools"), mentions `tickets/<ID>/...` et
    `docs/decisions/` (section "Workflow actuel"), ligne Inventaire pointant vers
    `automation/release-notes/prompt.md`.
  - `AGENTS.md` : 2 mentions de `automation/release-notes/`.
  - `.github/workflows/codex-release-notes.yml` : chemin `automation/release-notes/prompt.md` lu
    par le step d'assemblage du prompt (ligne ~91).
  - Le nouveau fichier de setup Codex extrait du README (voir plus haut) : chemin final
    `meta/automation/release-notes/README.md`, pas `automation/release-notes/README.md`.
- **Historique déjà clos (`tickets/15/`)** : contient des mentions textuelles de
  `docs/releases/...` et `automation/release-notes/prompt.md` dans sa prose (analyse/plan déjà
  clôturés). **Décision : ne pas les réécrire** — un ticket clos est un compte-rendu figé de ce qui
  était vrai au moment où il a été traité, pas une doc vivante à maintenir en synchronisation avec
  des réorganisations ultérieures (cohérent avec la façon dont un historique Git n'est jamais
  réécrit après un déplacement de fichier). Seul son *nouveau* chemin (`meta/tickets/15/`) doit
  être correct partout où il est *linké* depuis un document vivant (voir `README.md` ci-dessus).
- **Workflow `codex-release-notes.yml`** : ne lit ni ne référence `README.md` — aucun impact au-delà
  du chemin `automation/release-notes/prompt.md` déjà listé.

## Fichiers concernés (aperçu, détaillé dans `plan.md`)

- `README.md` — réorganisation (arbre + section "AI tools" raccourcie + chemins `meta/*`).
- `AGENTS.md` — chemins `automation/release-notes/` → `meta/automation/release-notes/`.
- `.github/workflows/codex-release-notes.yml` — chemin du prompt mis à jour.
- `meta/automation/release-notes/README.md` — nouveau, contenu extrait de "OpenAI Codex setup".
- Déplacements (`git mv`, contenu inchangé) : `tickets/` → `meta/tickets/`, `docs/` →
  `meta/docs/`, `automation/` → `meta/automation/`.

## Extension #2 : créer `CLAUDE.md` — séparer pitch (README) et instructions d'exécution (CLAUDE.md)

Constat de l'utilisateur, en pointant précisément les sections "Comment utiliser ce repo" et
"Écrire dans ce repo" : leur contenu n'est pas un pitch/une présentation pour un lecteur GitHub
quelconque, ce sont des **instructions d'exécution** — comment adapter un fichier copié, quelle
règle respecter en écrivant dans ce repo, quel processus suivre pour un ticket. Ce n'est pas
propre à ces deux sections : `## Comment ce repo lui-même est versionné` et `## Workflow actuel :
traiter un ticket de bout en bout` ont exactement la même nature (ce dernier est même déjà rédigé
à la première personne — "c'est moi qui committe" — donc littéralement le mode opératoire de
Claude Code sur ce repo, pas un texte de présentation).

**Symétrie avec l'existant** : Codex a déjà son fichier d'instructions dédié, `AGENTS.md`, distinct
du README. Créer `CLAUDE.md` (convention Claude Code : chargé automatiquement en contexte de
session sur ce repo, comme `AGENTS.md` l'est pour Codex) reproduit exactement le même principe pour
Claude Code — cohérent avec l'axe Claude/Codex déjà traité dans ce ticket, et un fichier de plus
qui ne peut pas être déplacé de la racine (même famille de contrainte que `.github/`/`AGENTS.md`/
`.claude/`).

**Répartition retenue** :

| Reste dans `README.md` (pitch/référence, pour tout lecteur) | Va dans `CLAUDE.md` (mode opératoire, chargé par Claude Code) |
|---|---|
| Intro, `## Structure`, `## AI tools` (déjà court), `## Inventaire`, `## Origine`, `## Statut` | `## Écrire dans ce repo`, `## Comment ce repo est versionné`, `## Workflow actuel : traiter un ticket`, le détail de `## Comment utiliser ce repo` |

`## Comment utiliser ce repo` est un cas limite : c'est aussi la promesse centrale du repo pour un
lecteur GitHub sans Claude Code (quelqu'un qui vient juste copier-coller à la main). **Décision** :
garder un résumé de quelques lignes dans le README (le principe : copier tel dossier, l'adapter) et
renvoyer vers `CLAUDE.md` pour le détail par dossier (checklist `> À adapter par projet`) — plutôt
que de tout retirer du README (perdrait l'utilisabilité pour un lecteur sans Claude Code) ou de
tout dupliquer (dérive garantie entre les deux fichiers).

**Vérification liens** : tous les liens internes des sections déplacées (`rules/hooks.md`,
`rules/git-flow.md`, `rules/general-coding.md`, `rules/docs-structure.md`, skills cités) sont déjà
relatifs à la racine du repo — `CLAUDE.md` étant lui aussi à la racine, aucun de ces liens ne
change. Seul le lien vers `CLAUDE.md` lui-même est ajouté (depuis le résumé conservé dans le
README, et depuis `## AI tools` si pertinent).
